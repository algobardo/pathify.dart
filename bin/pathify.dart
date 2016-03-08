library dpathify;

import "dart:io";
import "dart:convert";

import "package:path/path.dart" as path;
import "package:yaml/yaml.dart" as yaml;
import "package:ansicolor/ansicolor.dart";

void main(List<String> args) {
  if (args.length < 2 || (args[1] != "forth" && args[1] != "back")) {
    print("Usage: pathify <root> <direction> \n direction: forth | back");
    exit(-1);
  }

  print("- Loading exclude file");
  List<String> ignores = [];
  try {
    ignores = new File(path.join(args.first, ".pathifygnore")).readAsStringSync().split("\n").map((s) => s.trim());
  }
  catch(e, stacktrace) {
    print("  - Unable to find configuration file");
  }

  print("- Collecting packages and dependencies");

  List<String> packages = listPackages(args.first, ignores);

  print("- Found ${packages.join(",")}");

  if(args[1] == "forth") {
    JsonEncoder je = new JsonEncoder.withIndent("  ");

    Map<String, String> processedPackageNamer = new Map();
    Map<String, String> processedPackageResolver = new Map();
    Map<String, Map> processedPackagePubspec = new Map();

    for (String pubspec in packages) {
      String fileContent = new File(pubspec).readAsStringSync();
      Map doc = JSON.decode(JSON.encode(yaml.loadYaml(fileContent)));
      if(processedPackagePubspec[doc["name"]] != null) 
        print("WARNING: duplicate entry ${doc["name"]}");
      processedPackagePubspec[doc["name"]] = doc;
      processedPackageResolver[doc["name"]] = path.dirname(pubspec);
      processedPackageNamer[pubspec] = doc["name"];

      File dest = new File(path.join(path.dirname(pubspec), "pubspec.yaml.orig"));
      if (dest.existsSync()) {
        print(" -- Skipped $pubspec, because already pathified");
      }
      else {
        new File(path.join(path.dirname(pubspec), "pubspec.yaml.orig")).writeAsStringSync(fileContent);
      }
    }

    print("- Overwriting pubspecs");

    for (String pubspec in packages) {
      String name = processedPackageNamer[pubspec];
      print("Overwriting pubspec in ${path.dirname(pubspec)}");
      Map doc = processedPackagePubspec[name];
      Map deps = doc["dependencies"];
      if (deps != null) {
        for (String key in deps.keys) {
          if (processedPackageResolver[key] != null) {
            deps[key] = {"path": path.relative(processedPackageResolver[key], from: processedPackageResolver[name])};
          }
        }
      }

      new File(pubspec).writeAsStringSync(je.convert(doc));
    }
  }
  else {
    for (String pubspec in packages) {
      print("Reverting pubspec in ${path.dirname(pubspec)}");
      String orig = path.join(path.dirname(pubspec), "pubspec.yaml.orig");
      var origFile = new File(orig);
      if(origFile.existsSync())
        origFile.renameSync(pubspec);
    }
  }


}


List<String> listPackages(String root, [List<String> ignores = const []]) =>
  new Directory(root)
      .listSync(recursive: true, followLinks: false)
      .where((FileSystemEntity f) => f is File && path.basename(f.path) == "pubspec.yaml" && !ignores.map((String ptn) => ptn.matchAsPrefix(f.path) != null).contains(true) )
      .map((File f) => f.path);

