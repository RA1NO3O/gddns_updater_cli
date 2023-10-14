# Google DDNS

此工具旨在自动化更新Google DDNS记录过程。

## 需求开发环境

* [Dart SDK](https://dart.dev/get-dart)

## 项目目录说明

* 库代码: `lib/`
* 单元测试: `test/`
* 可执行文件: `build/`

## 编译指令

```shell
dart compile exe lib/main.dart -o build/gddns_updater.exe
```

> PS: 可能需要先创建build目录。