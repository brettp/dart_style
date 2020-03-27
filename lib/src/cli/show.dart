// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:path/path.dart' as p;

/// Which file paths should be printed.
abstract class Show {
  /// Only files whose formatting changed.
  static const Show changed = _ChangedShow();

  /// The legacy dartfmt output style when overwriting files.
  static const Show overwrite = _OverwriteShow();

  /// The legacy dartfmt output style in "--dry-run".
  static const Show dryRun = _DryRunShow();

  const Show._();

  /// The display path to show for [file] which is in [directory].
  ///
  /// In the old CLI, this does not include [directory], since the directory
  /// name is printed separately. The new CLI only prints file paths, so this
  /// includes the root directory to disambiguate which directory the file is
  /// in.
  String displayPath(String directory, String file) => p.normalize(file);

  /// Describes a file that was processed.
  ///
  /// Returns whether or not this file should be displayed.
  bool file(String path, {bool changed, bool overwritten}) => false;

  /// Describes the directory whose contents are about to be processed.
  void directory(String path) {}

  /// Describes the symlink at [path] that wasn't followed.
  void skippedLink(String path) {}

  /// Describes the hidden [path] that wasn't processed.
  void hiddenPath(String path) {}

  void _showFileChange(String path, {bool overwritten}) {
    if (overwritten) {
      print('Formatted $path');
    } else {
      print('Changed $path');
    }
  }
}

class _ChangedShow extends Show {
  const _ChangedShow() : super._();

  @override
  bool file(String path, {bool changed, bool overwritten}) {
    if (changed) _showFileChange(path, overwritten: overwritten);
    return changed;
  }
}

class _OverwriteShow extends Show {
  const _OverwriteShow() : super._();

  @override
  String displayPath(String directory, String file) =>
      p.relative(file, from: directory);

  @override
  bool file(String path, {bool changed, bool overwritten}) => true;

  @override
  void directory(String directory) {
    print('Formatting directory $directory:');
  }

  @override
  void skippedLink(String path) {
    print('Skipping link $path');
  }

  @override
  void hiddenPath(String path) {
    print('Skipping hidden path $path');
  }
}

class _DryRunShow extends Show {
  const _DryRunShow() : super._();

  @override
  String displayPath(String directory, String file) =>
      p.relative(file, from: directory);

  @override
  bool file(String path, {bool changed, bool overwritten}) {
    if (changed) print(path);
    return true;
  }
}
