import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:gddns_updater_cli/zxinc_resp.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: '帮助')
    ..addOption('u4', help: 'ipv4用户名')
    ..addOption('p4', help: 'ipv4密码')
    ..addOption('d4', help: 'ipv4域名')
    ..addOption('u6', help: 'ipv6用户名')
    ..addOption('p6', help: 'ipv6密码')
    ..addOption('d6', help: 'ipv6域名');

  /// 处理参数
  final parsedArgs = parser.parse(args);

  if (parsedArgs['help'] == true || parsedArgs.rest.isNotEmpty) {
    return print(parser.usage);
  }

  final String usernameV4 = parsedArgs['u4'] ?? '',
      passwordV4 = parsedArgs['p4'] ?? '',
      domainV4 = parsedArgs['d4'] ?? '',
      usernameV6 = parsedArgs['u6'] ?? '',
      passwordV6 = parsedArgs['p6'] ?? '',
      domainV6 = parsedArgs['d6'] ?? '';

  print('正在更新 Google DDNS.');

  final header = <String, String>{
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/118.0.0.0 '
        'Safari/537.36 '
        'Edg/118.0.2088.17',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;'
        'q=0.9,en;'
        'q=0.8,en-GB;'
        'q=0.7,en-US;q=0.6',
    'Authorization': 'Basic base64-encoded-auth-string'
  };

  const zxincDomain = 'ip.zxinc.org',
      zxincApiPath = '/api.php',
      zxincParams = {'type': 'json'};

  final zxincIpv4Uri = Uri.https('v4.$zxincDomain', zxincApiPath, zxincParams),
      zxincIpv6Uri = Uri.https('v6.$zxincDomain', zxincApiPath, zxincParams);

  const googleDomainsDomain = 'domains.google.com',
      googleDDNSApiPath = '/nic/update';

  FutureOr<void> zxincIpOnRespV4(resp) async {
    if (resp is! http.Response) {
      throw HttpException('resp is not http.Response', uri: zxincIpv4Uri);
    }
    print(resp.body);
    final json = jsonDecode(resp.body);
    if (json is! Map<String, dynamic>) {
      throw FormatException('resp.body is not Map<String, dynamic>', json);
    }
    final info = ZxIncResp.fromJson(json);
    if (info.myip.isEmpty) throw Exception('myip is empty');
    final googleDDNSUrlV4 = Uri.https(
        '$usernameV4:$passwordV4@$googleDomainsDomain',
        googleDDNSApiPath,
        {'hostname': domainV4, 'myip': info.myip});

    final result = await http.get(googleDDNSUrlV4);
    print(result.body);
  }

  FutureOr<void> zxincIpOnRespV6(resp) async {
    if (resp is! http.Response) {
      throw HttpException('resp is not http.Response', uri: zxincIpv6Uri);
    }
    print(resp.body);
    final json = jsonDecode(resp.body);
    if (json is! Map<String, dynamic>) {
      throw FormatException('resp.body is not Map<String, dynamic>', json);
    }
    final info = ZxIncResp.fromJson(json);
    if (info.myip.isEmpty) throw Exception('myip is empty');

    final googleDDNSUrlV6 = Uri.https(
        '$usernameV6:$passwordV6@$googleDomainsDomain',
        googleDDNSApiPath,
        {'hostname': domainV6, 'myip': info.myip});
    final result = await http.get(googleDDNSUrlV6);
    print(result.body);
  }

  if (usernameV4.isNotEmpty && passwordV4.isNotEmpty && domainV4.isNotEmpty) {
    print('正在获取当前 IPV4 地址...');
    http.get(zxincIpv4Uri, headers: header).then(zxincIpOnRespV4);
  }

  if (usernameV6.isNotEmpty && passwordV6.isNotEmpty && domainV6.isNotEmpty) {
    print('正在获取当前 IPV6 地址...');
    http.get(zxincIpv6Uri, headers: header).then(zxincIpOnRespV6);
  }
}
