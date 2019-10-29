# get_jetson_nano_thermal

## 使い方
`get_jetson_nano_thermal.sh`を`/usr/local/bin/`に設置

以下、root権限で作業すること。
```
# cp ./get_jetson_nano_thermal.sh /usr/local/bin/
```

引数なしで起動すると、helpが表示される。
```
$ /usr/local/bin/get_jetson_nano_thermal.sh 
/usr/local/bin/get_jetson_nano_thermal.sh type
Type is ..
0 : A0
1 : CPU
2 : GPU
3 : PLL
4 : PMIC-Die
```

GPUの温度を知りたい場合、引数に`2`を付けて起動する。
戻り値の単位は、摂氏。
```
$ /usr/local/bin/get_jetson_nano_thermal.sh 2
18
```

# net-snmp経由で値を取得する方法
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
NET-SNMP-EXTEND-MIB::nsExtendOutLine."JSTA0".1 = STRING: 18
NET-SNMP-EXTEND-MIB::nsExtendOutLine."JSTCPU".1 = STRING: 18
NET-SNMP-EXTEND-MIB::nsExtendOutLine."JSTGPU".1 = STRING: 16
NET-SNMP-EXTEND-MIB::nsExtendOutLine."JSTPLL".1 = STRING: 100
NET-SNMP-EXTEND-MIB::nsExtendOutLine."JSTPMIC".1 = STRING: 17
```

nsExtensionsをOidで表記すると `.1.3.6.1.4.1.8072.1.3` になります。
```
# snmpwalk -On -c public -v2c jetson nsExtensions | less
.1.3.6.1.4.1.8072.1.3.2.1.0 = INTEGER: 5
.1.3.6.1.4.1.8072.1.3.2.2.1.2.5.74.83.84.65.48 = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
.1.3.6.1.4.1.8072.1.3.2.2.1.2.6.74.83.84.67.80.85 = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
.1.3.6.1.4.1.8072.1.3.2.2.1.2.6.74.83.84.71.80.85 = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
.1.3.6.1.4.1.8072.1.3.2.2.1.2.6.74.83.84.80.76.76 = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
.1.3.6.1.4.1.8072.1.3.2.2.1.2.7.74.83.84.80.77.73.67 = STRING: /usr/local/bin/get_jetson_nano_thermal.sh
(snip)
.1.3.6.1.4.1.8072.1.3.2.4.1.2.5.74.83.84.65.48.1 = STRING: 17
.1.3.6.1.4.1.8072.1.3.2.4.1.2.6.74.83.84.67.80.85.1 = STRING: 18
.1.3.6.1.4.1.8072.1.3.2.4.1.2.6.74.83.84.71.80.85.1 = STRING: 16
.1.3.6.1.4.1.8072.1.3.2.4.1.2.6.74.83.84.80.76.76.1 = STRING: 100
.1.3.6.1.4.1.8072.1.3.2.4.1.2.7.74.83.84.80.77.73.67.1 = STRING: 17
```