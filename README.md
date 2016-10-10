# pathify

This script allow to easily develop mutually dependent packages, using their live working directories on the file-system.
This seems to allow IntelliJ to handle refactoring better than ```dependency_overrides```.

# Usage

Execute 

```
pub run pathify <root> forth
```

to change all the ```pubspec.yaml``` in the entire directory tree so that any dependency of the kind

```
name:
  <remote ref>
```
is changed into

```
name:
  path: <path>
```
if the package ```name``` is found in root.

Execute

```
pathify <root> back
```

to revert the original pubspecs when needed, e.g. before committing.

# Activating globally 
```
pub global activate -sgit https://github.com/algobardo/pathify.dart.git
```
