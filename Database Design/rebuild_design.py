"""Generate the reviewed Inventory/Discovery SQL and DBML design artifacts.

Design only: never connects to a database. Run from any working directory.
This specification is authoritative; regenerate after changing table definitions.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent
INV = ROOT / '02_Device Inventory Management'
DISC = ROOT / '04_Network Discovery'
TABLES = []


def table(module, filename, name, columns, constraints=(), indexes=()):
    TABLES.append((module, filename, name, columns, constraints, indexes))


# column = (name, SQL type, SQL modifiers); SQL contains the full constraints.
ID = ('id', 'uuid', 'PRIMARY KEY DEFAULT gen_random_uuid()')
CREATED = ('created_at', 'timestamptz', 'NOT NULL DEFAULT now()')
UPDATED = ('updated_at', 'timestamptz', 'NOT NULL DEFAULT now()')

table(INV, '01_credentials.sql', 'credential_profiles', [
    ID, ('name', 'varchar(100)', 'NOT NULL UNIQUE'),
    ('username', 'varchar(100)', ''), ('password_encrypted', 'text', ''),
    ('enable_secret_encrypted', 'text', ''), ('snmp_community_ro_encrypted', 'text', ''),
    ('ssh_port', 'integer', 'NOT NULL DEFAULT 22 CHECK (ssh_port BETWEEN 1 AND 65535)'),
    ('snmp_port', 'integer', 'NOT NULL DEFAULT 161 CHECK (snmp_port BETWEEN 1 AND 65535)'),
    ('description', 'text', ''), ('created_by', 'uuid', ''), CREATED, UPDATED,
], [
    'CHECK ((username IS NULL) = (password_encrypted IS NULL))',
    'CHECK (enable_secret_encrypted IS NULL OR password_encrypted IS NOT NULL)',
    'CHECK (password_encrypted IS NOT NULL OR snmp_community_ro_encrypted IS NOT NULL)',
])
table(INV, '02_sites_and_groups.sql', 'sites', [
    ID, ('name', 'varchar(100)', 'NOT NULL UNIQUE'), ('location_detail', 'varchar(255)', ''),
    ('description', 'text', ''), CREATED, UPDATED,
])
table(INV, '02_sites_and_groups.sql', 'device_groups', [
    ID, ('name', 'varchar(100)', 'NOT NULL UNIQUE'),
    ('color_tag', 'varchar(7)', "CHECK (color_tag ~ '^#[0-9A-Fa-f]{6}$')"),
    ('description', 'text', ''), CREATED, UPDATED,
])
table(INV, '03_devices.sql', 'devices', [
    ID, ('management_ip', 'inet', 'NOT NULL UNIQUE CHECK (masklen(management_ip) IN (32, 128))'),
    ('hostname', 'varchar(255)', ''),
    ('device_type', 'varchar(20)', "NOT NULL DEFAULT 'unknown' CHECK (device_type IN ('router','switch','firewall','access_point','server','other','unknown'))"),
    ('role', 'varchar(30)', "CHECK (role IN ('core','distribution','access','edge_router','management','other'))"),
    ('vendor', 'varchar(50)', ''), ('model', 'varchar(100)', ''),
    ('os_version', 'varchar(100)', ''), ('serial_number', 'varchar(100)', ''),
    ('chassis_id_subtype', 'smallint', 'CHECK (chassis_id_subtype BETWEEN 1 AND 7)'),
    ('chassis_id', 'text', ''),
    ('site_id', 'uuid', 'REFERENCES sites(id) ON DELETE RESTRICT'),
    ('credential_profile_id', 'uuid', 'REFERENCES credential_profiles(id) ON DELETE RESTRICT'),
    ('platform', 'varchar(50)', ''),
    ('management_state', 'varchar(20)', "NOT NULL DEFAULT 'active' CHECK (management_state IN ('active','maintenance','retired'))"),
    ('reachability', 'varchar(20)', "NOT NULL DEFAULT 'unknown' CHECK (reachability IN ('unknown','reachable','unreachable'))"),
    ('enrollment_source', 'varchar(30)', "NOT NULL CHECK (enrollment_source IN ('manual_enrollment','auto_discovery','csv_import'))"),
    ('last_seen_at', 'timestamptz', ''), ('reachability_checked_at', 'timestamptz', ''),
    ('last_collected_at', 'timestamptz', 'NOT NULL'),
    ('uptime_seconds', 'bigint', 'CHECK (uptime_seconds >= 0)'),
    ('uptime_observed_at', 'timestamptz', ''),
    ('notes', 'text', ''), ('created_by', 'uuid', ''), CREATED, UPDATED,
], [
    'CHECK ((chassis_id IS NULL) = (chassis_id_subtype IS NULL))',
    'CHECK ((uptime_seconds IS NULL) = (uptime_observed_at IS NULL))',
    "CHECK (reachability = 'unknown' OR reachability_checked_at IS NOT NULL)",
    "CHECK (reachability <> 'reachable' OR last_seen_at IS NOT NULL)",
], [('site_id',), ('credential_profile_id',), ('hostname',)])
table(INV, '03_devices.sql', 'device_group_members', [
    ('device_id', 'uuid', 'NOT NULL REFERENCES devices(id) ON DELETE RESTRICT'),
    ('group_id', 'uuid', 'NOT NULL REFERENCES device_groups(id) ON DELETE CASCADE'),
    ('added_at', 'timestamptz', 'NOT NULL DEFAULT now()'),
], ['PRIMARY KEY (device_id, group_id)'], [('group_id',)])
table(INV, '04_device_interfaces.sql', 'device_interfaces', [
    ID, ('device_id', 'uuid', 'NOT NULL REFERENCES devices(id) ON DELETE RESTRICT'),
    ('if_index', 'integer', 'CHECK (if_index > 0)'),
    ('name', 'varchar(255)', 'NOT NULL'), ('mac_address', 'macaddr', ''),
    ('description', 'varchar(255)', ''),
    ('mode', 'varchar(20)', "NOT NULL DEFAULT 'unknown' CHECK (mode IN ('access','trunk','routed','loopback','svi','unknown'))"),
    ('access_vlan_id', 'integer', 'CHECK (access_vlan_id BETWEEN 1 AND 4094)'),
    ('admin_status', 'varchar(20)', "NOT NULL DEFAULT 'unknown' CHECK (admin_status IN ('up','down','testing','unknown'))"),
    ('oper_status', 'varchar(20)', "NOT NULL DEFAULT 'unknown' CHECK (oper_status IN ('up','down','testing','unknown','dormant','not_present','lower_layer_down'))"),
    ('speed_bps', 'bigint', 'CHECK (speed_bps >= 0)'),
    ('collected_at', 'timestamptz', 'NOT NULL'), ('retired_at', 'timestamptz', ''), UPDATED,
], [
    'UNIQUE (device_id, id)',
    "CHECK (access_vlan_id IS NULL OR mode = 'access')",
], [])
table(INV, '04_device_interfaces.sql', 'interface_ip_addresses', [
    ('interface_id', 'uuid', 'NOT NULL REFERENCES device_interfaces(id) ON DELETE RESTRICT'),
    ('address', 'inet', 'NOT NULL'),
], ['PRIMARY KEY (interface_id, address)'])

table(DISC, '04_discovery_scans.sql', 'discovery_scans', [
    ID, ('seed_ip', 'inet', 'NOT NULL CHECK (masklen(seed_ip) IN (32, 128))'),
    ('credential_profile_id', 'uuid', 'NOT NULL REFERENCES credential_profiles(id) ON DELETE RESTRICT'),
    ('status', 'varchar(20)', "NOT NULL DEFAULT 'queued' CHECK (status IN ('queued','running','succeeded','partial','failed','cancelled'))"),
    ('timeout_seconds', 'integer', 'NOT NULL DEFAULT 2 CHECK (timeout_seconds > 0)'),
    ('max_depth', 'integer', 'NOT NULL CHECK (max_depth >= 0)'),
    ('max_devices', 'integer', 'NOT NULL CHECK (max_devices > 0)'),
    ('environment', 'varchar(20)', "NOT NULL CHECK (environment IN ('physical','emulated'))"),
    ('initiated_by', 'uuid', ''), ('error_message', 'text', ''),
    ('requested_at', 'timestamptz', 'NOT NULL DEFAULT now()'),
    ('started_at', 'timestamptz', ''), ('finished_at', 'timestamptz', ''),
], [
    'CHECK (started_at IS NULL OR started_at >= requested_at)',
    'CHECK (finished_at IS NULL OR finished_at >= COALESCE(started_at, requested_at))',
    "CHECK ((status IN ('succeeded','partial','failed','cancelled')) = (finished_at IS NOT NULL))",
    "CHECK (status NOT IN ('running','succeeded','partial') OR started_at IS NOT NULL)",
], [('requested_at',)])
table(DISC, '05_collection_runs.sql', 'collection_runs', [
    ID, ('discovery_scan_id', 'uuid', 'REFERENCES discovery_scans(id) ON DELETE RESTRICT'),
    ('device_id', 'uuid', 'REFERENCES devices(id) ON DELETE RESTRICT'),
    ('target_ip', 'inet', 'NOT NULL CHECK (masklen(target_ip) IN (32, 128))'),
    ('credential_profile_id', 'uuid', 'NOT NULL REFERENCES credential_profiles(id) ON DELETE RESTRICT'),
    ('purpose', 'varchar(30)', "NOT NULL CHECK (purpose IN ('manual_enrollment','csv_import','discovery','recollect'))"),
    ('transport', 'varchar(20)', "NOT NULL CHECK (transport IN ('snmp','ssh'))"),
    ('environment', 'varchar(20)', "NOT NULL CHECK (environment IN ('physical','emulated'))"),
    ('status', 'varchar(20)', "NOT NULL DEFAULT 'queued' CHECK (status IN ('queued','running','succeeded','partial','failed','cancelled'))"),
    ('neighbor_status', 'varchar(20)', "NOT NULL DEFAULT 'not_attempted' CHECK (neighbor_status IN ('not_attempted','succeeded','failed','unsupported'))"),
    ('initiated_by', 'uuid', ''), ('error_message', 'text', ''),
    ('requested_at', 'timestamptz', 'NOT NULL DEFAULT now()'),
    ('started_at', 'timestamptz', ''), ('finished_at', 'timestamptz', ''),
], [
    'UNIQUE (id, device_id)',
    "CHECK ((purpose = 'discovery') = (discovery_scan_id IS NOT NULL))",
    "CHECK (status NOT IN ('succeeded','partial') OR device_id IS NOT NULL)",
    'CHECK (started_at IS NULL OR started_at >= requested_at)',
    'CHECK (finished_at IS NULL OR finished_at >= COALESCE(started_at, requested_at))',
    "CHECK ((status IN ('succeeded','partial','failed','cancelled')) = (finished_at IS NOT NULL))",
    "CHECK (status NOT IN ('running','succeeded','partial') OR started_at IS NOT NULL)",
], [('device_id', 'requested_at'), ('discovery_scan_id',), ('credential_profile_id',)])
table(DISC, '03_topology_links.sql', 'neighbor_observations', [
    ID, ('collection_run_id', 'uuid', 'NOT NULL'),
    ('local_device_id', 'uuid', 'NOT NULL'),
    ('local_interface_id', 'uuid', 'NOT NULL'),
    ('observation_key', 'varchar(255)', 'NOT NULL'),
    ('protocol', 'varchar(10)', "NOT NULL DEFAULT 'lldp' CHECK (protocol = 'lldp')"),
    ('remote_chassis_id_subtype', 'smallint', 'CHECK (remote_chassis_id_subtype BETWEEN 1 AND 7)'),
    ('remote_chassis_id', 'text', ''),
    ('remote_port_id_subtype', 'smallint', 'CHECK (remote_port_id_subtype BETWEEN 1 AND 7)'),
    ('remote_port_id', 'text', ''),
    ('remote_system_name', 'text', ''), ('remote_port_description', 'text', ''),
    ('remote_management_ip', 'inet', 'CHECK (masklen(remote_management_ip) IN (32, 128))'),
    ('observed_at', 'timestamptz', 'NOT NULL'),
], [
    'FOREIGN KEY (collection_run_id, local_device_id) REFERENCES collection_runs(id, device_id) ON DELETE RESTRICT',
    'FOREIGN KEY (local_device_id, local_interface_id) REFERENCES device_interfaces(device_id, id) ON DELETE RESTRICT',
    'UNIQUE (collection_run_id, observation_key)',
    'CHECK ((remote_chassis_id IS NULL) = (remote_chassis_id_subtype IS NULL))',
    'CHECK ((remote_port_id IS NULL) = (remote_port_id_subtype IS NULL))',
    'CHECK (remote_chassis_id IS NOT NULL OR remote_port_id IS NOT NULL OR remote_system_name IS NOT NULL OR remote_management_ip IS NOT NULL)',
], [('local_device_id', 'local_interface_id'), ('observed_at',)])


def render_dbml(rows):
    import re
    result = []
    for module, filename, name, columns, constraints, indexes in rows:
        result.append(f'Table {name} {{')
        for col, typ, options in columns:
            attrs = []
            if 'PRIMARY KEY' in options:
                attrs.append('pk')
            if 'NOT NULL' in options:
                attrs.append('not null')
            if 'UNIQUE' in options:
                attrs.append('unique')
            ref = re.search(r'REFERENCES (\w+)\((\w+)\)', options)
            if ref:
                attrs.append(f'ref: > {ref[1]}.{ref[2]}')
            default = re.search(r'DEFAULT (gen_random_uuid\(\)|now\(\)|\d+|\x27[^\x27]*\x27)', options)
            if default:
                value = default[1]
                attrs.append('default: ' + (f'`{value}`' if '(' in value else value))
            result.append(f'  {col} {typ}' + (' [' + ', '.join(attrs) + ']' if attrs else ''))
        idx = []
        for constraint in constraints:
            key = re.fullmatch(r'(PRIMARY KEY|UNIQUE) \(([^)]+)\)', constraint)
            if key:
                idx.append(f'    ({key[2]}) [' + ('pk' if key[1] == 'PRIMARY KEY' else 'unique') + ']')
        idx += ['    (' + ', '.join(i) + ')' for i in indexes]
        if idx:
            result += ['  indexes {', *idx, '  }']
        result += ['}', '']
        for constraint in constraints:
            ref = re.match(r'FOREIGN KEY \(([^)]+)\) REFERENCES (\w+)\(([^)]+)\)', constraint)
            if ref:
                result.append(f'Ref: {name}.({ref[1]}) > {ref[2]}.({ref[3]})')
    return '\n'.join(result).rstrip() + '\n'


def main():
    files = {}
    for module, filename, name, columns, constraints, indexes in TABLES:
        body = [f'    {col} {typ} {options}'.rstrip() for col, typ, options in columns]
        body += ['    ' + c for c in constraints]
        ddl = f'CREATE TABLE {name} (\n' + ',\n'.join(body) + '\n);\n'
        for i in indexes:
            ddl += f'CREATE INDEX idx_{name}_{"_".join(i)} ON {name} ({", ".join(i)});\n'
        files.setdefault(module / 'sql' / filename, []).append(ddl)
    files[INV / 'sql/04_device_interfaces.sql'].append('''-- ifIndex/name may change or be reused: uniqueness applies to current interfaces only.
CREATE UNIQUE INDEX uq_interface_current_index ON device_interfaces(device_id, if_index)
    WHERE retired_at IS NULL AND if_index IS NOT NULL;
CREATE UNIQUE INDEX uq_interface_current_name ON device_interfaces(device_id, name)
    WHERE retired_at IS NULL;
''')
    files[INV / 'sql/00_enums.sql'] = ['-- Values are constrained locally with CHECK; no duplicated PostgreSQL enums.\n-- PostgreSQL 14+ has built-in gen_random_uuid(); no extension needed.\n']
    files[INV / 'sql/05_device_enrollment_attempts.sql'] = ['-- Retired design: enrollment attempts now use Discovery/Collection collection_runs.\n-- purpose = manual_enrollment / csv_import; device_id stays NULL on unverified failures.\n']
    files[DISC / 'sql/00_enums.sql'] = ['-- No shared enums or extensions are recreated here. Apply Inventory first.\n']
    files[DISC / 'sql/01_devices.sql'] = ['-- Reference only. Owner: ../../02_Device Inventory Management/sql/03_devices.sql\n-- Discovery calls Inventory to upsert verified devices; never CREATE TABLE devices here.\n']
    files[DISC / 'sql/02_device_interfaces.sql'] = ['-- Reference only. Owner: ../../02_Device Inventory Management/sql/04_device_interfaces.sql\n-- Shared device_interfaces IDs are used by neighbor_observations.\n']
    header = '-- Generated by ../rebuild_design.py. Design for a NEW database, not a migration.\n'
    for path, chunks in files.items():
        path.write_text(header + '\n'.join(chunks), encoding='utf-8')
    inv_order = ['00_enums', '01_credentials', '02_sites_and_groups', '03_devices', '04_device_interfaces', '05_device_enrollment_attempts']
    disc_order = ['00_enums', '01_devices', '02_device_interfaces', '04_discovery_scans', '05_collection_runs', '03_topology_links']
    for module, filename, order in [(INV, 'device_inventory.sql', inv_order), (DISC, 'network_discovery.sql', disc_order)]:
        combined = '\n'.join((module / 'sql' / f'{f}.sql').read_text(encoding='utf-8') for f in order)
        (module / filename).write_text(combined, encoding='utf-8')
    dbml_header = '// Generated design. SQL is authoritative for CHECK, partial indexes and delete policy.\n'
    (INV / 'device_inventory.dbml').write_text(dbml_header + render_dbml([t for t in TABLES if t[0] == INV]), encoding='utf-8')
    (DISC / 'network_discovery.dbml').write_text(dbml_header + '// Fragment: append to Inventory DBML, or open ../mynetmate.dbml. No duplicate external tables.\n' + render_dbml([t for t in TABLES if t[0] == DISC]), encoding='utf-8')
    (ROOT / 'mynetmate.dbml').write_text(dbml_header + render_dbml(TABLES), encoding='utf-8')


if __name__ == '__main__':
    main()
