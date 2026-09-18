// Usage: node verify_schema.cjs <temporary directory containing node_modules>
// Requires @electric-sql/pglite and @dbml/core; no project DB or network is used.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const { PGlite } = require(path.join(process.argv[2], 'node_modules/@electric-sql/pglite'));
const { Parser } = require(path.join(process.argv[2], 'node_modules/@dbml/core'));
const root = __dirname;
const read = p => fs.readFileSync(path.join(root,p),'utf8');
const inv = '02_Device Inventory Management/';
const disc = '04_Network Discovery/';
(async () => {
  Parser.parse(read('mynetmate.dbml'), 'dbml');
  Parser.parse(read(inv+'device_inventory.dbml')+'\n'+read(disc+'network_discovery.dbml'),'dbml');
  assert(!/CREATE TABLE devices\b|CREATE TABLE device_interfaces\b/.test(read(disc+'network_discovery.sql').replace(/--[^\n]*/g,'')));
  const db = new PGlite();
  let passed = 0;
  async function reject(label, sql, code) {
    await db.exec('BEGIN');
    try {
      await assert.rejects(db.exec(sql), e => { if(![code].flat().includes(e.code)) console.error(label, e.code, e.message); return [code].flat().includes(e.code); }, label);
      passed++;
    } finally { await db.exec('ROLLBACK'); }
  }
  for (const p of [inv+'device_inventory.sql',disc+'network_discovery.sql',inv+'sql/99_seed_data.sql',disc+'sql/99_seed_data.sql']) await db.exec(read(p));
  const counts = await db.query("SELECT (SELECT count(*)::int FROM devices) AS devices, (SELECT count(*)::int FROM neighbor_observations) AS observations");
  assert.deepEqual(counts.rows[0],{devices:2,observations:3});
  passed++;
  const failed = await db.query("SELECT device_id FROM collection_runs WHERE purpose='manual_enrollment'");
  assert.equal(failed.rows[0].device_id,null); passed++;
  await reject('duplicate management IP', "INSERT INTO devices(management_ip,enrollment_source,last_collected_at) VALUES ('192.168.10.1','manual_enrollment',now())",'23505');
  await reject('unverified device lacks collection time', "INSERT INTO devices(management_ip,enrollment_source) VALUES ('192.168.10.50','manual_enrollment')",'23502');
  await reject('credential bundle must have an auth method', "INSERT INTO credential_profiles(name) VALUES ('empty')",'23514');
  await reject('SSH username requires password', "INSERT INTO credential_profiles(name,username) VALUES ('invalid','admin')",'23514');
  await reject('run and local device must match', "UPDATE neighbor_observations SET local_device_id='44444444-4444-4444-4444-444444444402', local_interface_id='55555555-5555-5555-5555-555555555502' WHERE id='99999999-9999-9999-9999-999999999901'",'23503');
  await reject('local interface must belong to collection device', "UPDATE neighbor_observations SET local_interface_id='55555555-5555-5555-5555-555555555502' WHERE id='99999999-9999-9999-9999-999999999901'",'23503');
  await reject('duplicate ingestion key', "UPDATE neighbor_observations SET observation_key='lldp:0:1:1' WHERE id='99999999-9999-9999-9999-999999999903'",'23505');
  await reject('physical evidence is LLDP only', "UPDATE neighbor_observations SET protocol='cdp'",'23514');
  await reject('ID requires subtype', "UPDATE neighbor_observations SET remote_chassis_id_subtype=NULL",'23514');
  await reject('retain device history', "DELETE FROM devices WHERE management_ip='192.168.10.1'",['23503','23001']);
  await reject('retain interface evidence', "DELETE FROM device_interfaces WHERE id='55555555-5555-5555-5555-555555555502'",['23503','23001']);
  await reject('invalid completion time', "UPDATE collection_runs SET finished_at='2020-01-01' WHERE status='succeeded'",'23514');
  await reject('successful run needs device', "UPDATE collection_runs SET status='succeeded' WHERE purpose='manual_enrollment'",'23514');
  await reject('terminal state requires completion time', "UPDATE discovery_scans SET finished_at=NULL",'23514');
  await reject('access VLAN is not trunk VLAN', "UPDATE device_interfaces SET mode='trunk',access_vlan_id=10",'23514');
  await reject('current ifIndex unique', "INSERT INTO device_interfaces(device_id,if_index,name,collected_at) VALUES ('44444444-4444-4444-4444-444444444401',1,'other',now())",'23505');
  await db.exec("UPDATE device_interfaces SET retired_at=now() WHERE id='55555555-5555-5555-5555-555555555501'");
  await db.exec("INSERT INTO device_interfaces(device_id,if_index,name,collected_at) VALUES ('44444444-4444-4444-4444-444444444401',1,'GigabitEthernet0/1',now())");
  passed++; // retired identity preserved, reused index/name accepted
  const defaults = await db.query("SELECT admin_status,oper_status,mode FROM device_interfaces WHERE retired_at IS NULL");
  assert(defaults.rows.every(r=>r.admin_status==='unknown'&&r.oper_status==='unknown'&&r.mode==='unknown')); passed++;
  const ips=await db.query("SELECT count(*)::int AS n FROM interface_ip_addresses");
  assert.equal(ips.rows[0].n,2); passed++;
  const tables = await db.query("SELECT count(*)::int AS n FROM information_schema.tables WHERE table_schema='public'");
  console.log(JSON.stringify({validation:'passed',tables:tables.rows[0].n,behaviorChecks:passed,dbml:'combined and concatenated fragments parsed',engine:'PGlite embedded PostgreSQL'},null,2));
  await db.close();
})().catch(e=>{console.error(e);process.exit(1)});
