library dartling_gen;

import 'dart:io';
import 'package:dartling/dartling.dart';

part 'doc_gen.dart';
part 'lib_gen.dart';
part 'test_gen.dart';
part 'web_gen.dart';

String libraryName;
String domainName;
String modelName;

Repo dartlingRepository;
Domain dartlingDomain;
Model dartlingModel;

String modelJson;

String firstLetterToUpper(String text) {
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

Directory genDir(String path) {
  var dir = new Directory(path);
  if (dir.existsSync()) {
    print('directory ${path} exists already');
  } else {
    dir.createSync();
    print('directory created: ${path}');
  }
  return dir;
}

File genFile(String path) {
  File file = new File(path);
  if (file.existsSync()) {
    print('file ${path} exists already');
  } else {
    file.createSync();
    print('file created: ${path}');
  }
  return file;
}

addText(File file, String text) {
  IOSink writeSink = file.openWrite();
  writeSink.write(text);
  writeSink.close();
}

File getFile(String path) {
  return genFile(path);
}

String readTextFromFile(File file) {
  String fileText = file.readAsStringSync();
  return fileText;
}

genGitignore(File file) {
  var text = '''
.DS_Store
build
packages
pubspec.lock
*~
  ''';
  addText(file, text);
}

genReadme(File file) {
  var text = '';
  text = '${text}# ${domainName}_${modelName} \n';
  text = '${text}\n';
  text = '${text}**Categories**: dartling, class models. \n';
  text = '${text}\n';
  text = '${text}## Description: \n';
  text = '${text}${domainName}_${modelName} project uses \n';
  text = '${text}[dartling] (https://github.com/dzenanr/dartling) for the model.';
  addText(file, text);
}

/*
genPubspec(File file) {
  var text = '''
name: ${domainName}_${modelName}
version: 0.0.1
description: ${domainName}_${modelName} application that uses dartling for its model.
author: Your Name
homepage: http://ondart.me/
documentation:
environment:
  sdk: '>=1.2.0 <2.0.0'
dependencies:
  browser: '>=0.10.0 <0.11.0'
  dartling:
    git: 'https://github.com/dzenanr/dartling.git'
  dartling_default_app:
    git: 'https://github.com/dzenanr/dartling_default_app.git'
  ''';
  addText(file, text);
}
 */

genPubspec(File file) {
  var text = '''
name: ${domainName}_${modelName}
version: 0.0.1
description: ${domainName}_${modelName} application that uses dartling for its model.
author: Your Name
homepage: http://ondart.me/
documentation:
dependencies:
  browser: any
  dartling:
    git: https://github.com/dzenanr/dartling.git
  dartling_default_app:
    git: https://github.com/dzenanr/dartling_default_app.git
  ''';
  addText(file, text);
}

genProject(String gen, String projectPath) {
  if (gen == '--genall') {
    genDir(projectPath);
    genDoc(projectPath);
    genLib(gen, projectPath);
    genTest(projectPath, dartlingModel);
    genWeb(projectPath);
    File gitignore = genFile('${projectPath}/.gitignore');
    genGitignore(gitignore);
    File readme = genFile('${projectPath}/README.md');
    genReadme(readme);
    File pubspec = genFile('${projectPath}/pubspec.yaml');
    genPubspec(pubspec);
  } else if (gen == '--gengen') {
    genLib(gen, projectPath);
  } else {
    print('valid gen argument is either --genall or --gengen');
  }
}

createDomainModel(String projectPath) {
  var modelJsonFilePath = '${projectPath}/model.json';
  File modelJsonFile = getFile(modelJsonFilePath);
  modelJson = readTextFromFile(modelJsonFile);
  if (modelJson.length == 0) {
    print('missing json of the model');
  } else {
    dartlingRepository = new Repo();
    dartlingDomain = new Domain(firstLetterToUpper(domainName));
    dartlingModel = fromJsonToModel(modelJson, dartlingDomain, 
        firstLetterToUpper(modelName));
    dartlingRepository.domains.add(dartlingDomain);
  }
}

void main(List<String> args) {
  // --genall C:/Users/ridjanod/dart/project domain model
  // --gengen C:/Users/ridjanod/dart/project domain model

  // --genall /home/dr/dart/project domain model
  // --gengen /home/dr/dart/project domain model
  if (args.length == 4 && (args[0] == '--genall' || args[0] == '--gengen')) {
    domainName = args[2];
    modelName = args[3];
    domainName =  domainName.toLowerCase();
    modelName = modelName.toLowerCase();
    if (domainName == modelName) {
      throw new DartlingError('domain and model names must be different');
    }
    if (domainName == 'domain') {
      throw new DartlingError('domain cannot be the domain name');
    }
    if (modelName == 'model') {
      throw new DartlingError('model cannot be the model name');
    }
    libraryName = '${domainName}_${modelName}';
    createDomainModel(args[1]); // project path as argument
    genProject(args[0], args[1]);
  } else {
    print('arguments are not entered properly in Run/Manage Launches of Dart Editor');
  }
}
