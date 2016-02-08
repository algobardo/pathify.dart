library dpathify;

import "dart:io";
import "package:args/args.dart";
import "package:path/path.dart" as path;
import "package:yaml/yaml.dart";
import "package:ansicolor/ansicolor.dart";

void main(List<String> args) {

  if(args.length < 1) {
    print("Specify a root");
    exit(-1);
  }

  List<String> packages = listPackages(args.first);

  print("Collecting packages and dependencies");

  Map<String, String> processedPackageResolver = new Map();
  Map<String, Map> processedPackagePubspec = new Map();

  for(String pubspec in packages) {
    String fileContent = new File(pubspec).readAsStringSync();
    Map doc = loadYaml(fileContent);
    processedPackagePubspec[doc["name"]] = doc;
    processedPackageResolver[doc["name"]] = path.dirname(pubspec);
    new File(path.join(path.dirname(pubspec), "pubspec.yaml.orig")).writeAsStringSync(fileContent);
  }

/*
Map deps = doc["dependencies"];
Map devdeps = doc["dev_dependencies"];

if(deps != null) {
deps.keys
}
*/


}


List<String> listPackages(String root) =>
  new Directory(root)
      .listSync(recursive: true, followLinks: false)
      .where((FileSystemEntity f) => f is File && path.basename(f.path) == "pubspec.yaml")
      .map((File f) => f.path);
