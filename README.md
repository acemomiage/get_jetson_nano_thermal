# get_jetson_nano_thermal

## 使い方
`get_jetson_nano_thermal.sh`を`/usr/local/bin/`に設置

以下、root権限で作業すること
```
# cp ./get_jetson_nano_thermal.sh /usr/local/bin/
```

## snmpdの設定ファイルを修正
```
# cp -pi /etc/snmp/snmpd.conf{,.backup}
# vim /etc/snmp/snmpd.conf
```

snmpd.confに以下の5行を追記
```
extend JSTA0   /usr/local/bin/get_jetson_nano_thermal.sh 1
extend JSTCPU  /usr/local/bin/get_jetson_nano_thermal.sh 2
extend JSTGPU  /usr/local/bin/get_jetson_nano_thermal.sh 3
extend JSTPLL  /usr/local/bin/get_jetson_nano_thermal.sh 4
extend JSTPMIC /usr/local/bin/get_jetson_nano_thermal.sh 5
```

snmpd processをrestart
```
# systemctl restart snmpd
```

## 値が取れるか確認
```
# snmpwalk -v2c -c public <jetson's ip addr.> nsExtensions
NET-SNMP-EXTEND-MIB::nsExtendNumEntries.0 = INTEGER: 5
NET-SNMP-EXTEND-MIB::nsExtendCommand."JSTA0" = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
NET-SNMP-EXTEND-MIB::nsExtendCommand."JSTCPU" = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
NET-SNMP-EXTEND-MIB::nsExtendCommand."JSTGPU" = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
NET-SNMP-EXTEND-MIB::nsExtendCommand."JSTPLL" = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
NET-SNMP-EXTEND-MIB::nsExtendCommand."JSTPMIC" = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
(snip)
```

nsExtensionsをOidで表記すると `.1.3.6.1.4.1.8072.1.3` になります。

