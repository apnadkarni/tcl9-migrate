# Migration tool for Tcl 9

This software is intended to help identify changes needed for migrating
Tcl 8 scripts to Tcl 9. It has two modes of operation:

- a static analyzer based on Nagelfar that runs under both Tcl 8.6 and 9
  logging warnings for potential incompatibilities.

- a runtime analyzer. This is intended to only run under Tcl 9. It attempts to
  fix up invalid code (e.g. encodings, tilde references) at run time allowing
  the program to continue to run but logs warnings to stderr.

See the **Warnings** section for the checks implemented by the tool.

It is expected the runtime analyzer is run only after fixing the
incompatibilities reported by the static analyzer.

**These tools only target Tcl script level incompatibilities.**
In particular, neither the C API nor Tk command incompatibilities
are addressed.

## Requirements

The detection and checks for file encodings requires the ICU libraries to be
present on the system at runtime. These should already be present on Windows
11 and recent versions of Windows 10. On other platforms, install them via
the package manager if not already installed.

## Static checks

The static analyzer may be run either with Tcl 8.6 or 9. However, the latter
is strongly suggested as the former will not detect encoding error
conditions in source files.

To run the static analyzer,

```
tclsh migrate.tcl check ?options? ?--? ?GLOBPAT ...?
```

where `GLOBPAT` is a file glob pattern. Each file matching the pattern is
examined and warnings for any potential incompatibilities are printed to
standard output. If the `--encodingsonly` or `-e` option is specified, no
static analysis is done, only file encodings are checked.

The warnings and errors generated by default only include those related
to migration. If the `--all` or `-a` option is specified, all warnings
from Nagelfar are reported.

It is recommended that static analysis be done in the following steps.

1. Run with the `--encodingsonly` option to first detect source files that
are not in UTF-8 encodings. These should be converted to UTF-8 encoding
(preferable) or the corresponding `source` commands fixed to add the
appropriate `-encoding` option. Note false positives are possible as the
tool only checks file encoding and not how they are sourced. (Note: the
runtime checks on the other hand, do check actual source encodings and
generate fewer false positives. **This step must be done with a Tcl 9
tclsh.**

2. Run without any options to report any required changes related to
migration. Check and fix if necessary any reported issues.

3. Optionally, run with the `--all` option to report **all** warnings and
error messages from Nagelfar including those not related to migration.

To minimize false positives, particularly with reference to variable
declarations, it is recommended that related source files be checked in one
step and not individually. At the same time, the tool is not exactly a speed
demon, so some patience is needed on large source bases.

By default files larger than 100000 bytes are skipped. Specify the
--sizelimit option to change this value. To disable size limits,
specify the value as `0`.

### Reducing message volume

The static checker may generate a large number of false positives,
particularly for command like `string is` and `glob`. Aside from
`egrep -v` there are a couple of mechanisms for filtering these.

#### Filter by severity

Messages are classified into three severity levels:

* `N` - notes a difference in behavior between Tcl 8 and 9 that may or may not
be an issue.

* `W` - warns that the line in question is *likely* to result in a bug
or unexpected behaviour.

* `E` - flags lines that are definitely errors in Tcl 9 and should be fixed.

The `--severity` option for the `check` command can be used to filter
based on severity level.

#### Ignoring false positives

You can use Nagelfar's inline comment [facility](https://nagelfar.sourceforge.net/inlinecomments.html)
to reduce the number of false positives produced. To prevent
a line from being reported by the tool, add the following line
before the line in question. Note exactly two `#` characters
followed by `nagelfar` with no intervening space.

```
##nagelfar ignore
```

See the above Nagelfar documentation link for additional features
related to reducing false positives.

This facility is useful when the code actually takes different
paths based on the Tcl version and you do not want the Tcl 8 path
to be flagged.

## Runtime checks

The runtime checks are intended to be used with Tcl 9. To enable the
checks, either extract the distribution into a directory on Tcl's
`auto_path`, or use the `install` command to install the package.

```
tclsh migrate.tcl install ?DIR?
```

If `DIR` is not specified the package will be installed in the last
directory in `auto_path` that is located in the native file system.

Then at the top of your main application, add the following lines:

```
package require tcl9migrate
tcl9migrate::runtime::enable
```

Note the main application file must have the correct encoding (UTF-8). As
recommended, use the static analyzer first to verify this. If other sourced are
not, appropriate warnings will be generated.

The runtime checks include

- Correct file encodings. In case of encoding failures, the correct encoding
is **guessed** to permit the program to continue and a warning printed to
standard error.

- Use of tildes in `open**, `file** and similar commands. These are expanded
appropriately allowing the program to run with a warning printed to standard
error.

## Warnings

**Both static and runtime warnings may include false positives.**
Any changes should be made keeping that in mind.

The following warnings may be emitted by the tool:

### [DATAENCODING]

The encoding for a data file argument to `open` was not that expected. The
expected encoding is the one returned by `encoding system`. The generated
message may be ignored if there is already a following call to `fconfigure`
to set the appropriate encoding. The runtime check does not detect that.

In all cases, the suggested encoding is **only a guess** and should be
verified by other means. The referenced file should be converted as
appropriate or an appropriate `fconfigure` command added to set the correct
encoding. On Unix/Linux, encoding conversion can be done with the `iconv`
utility which is present in most distributions. It is also available for
Windows as a download from several sites.

### [CHANENCODING]

The `fconfigure -encoding` and `chan configure -encoding` options
do not accept `binary` or the empty string as valid values. To configure
for binary I/O, use `-translation binary` instead.

### [EOFCHAR]

The `fconfigure -eofchar` and `chan configure -eofchar` option values must
be a single character which specifies the EOF character on input. Tcl 9 does
not support EOF characters on output. They must be explicitly written.

### [FMTSPEC]

In Tcl 8, if a size modifier was not present for an integer `format`
or `scan`, the value would be truncated to the word size of the platform.
In Tcl 9, the value is always truncated to 32 bits irrespective of platform.

### [GLOBCOMPLAIN]

Unlike Tcl 8, the `glob` command in Tcl 9 will not raise an error if no files
match the specified pattern. Code that expects an error to be raised in such
instances will need to be changed to explicitly check for an empty return list.
To keep code portable between Tcl 8 and 9, add the `-nocomplain` option.

### [LOADCASE]

The initialization function name argument passed to the `load` command
as the second (optional) argument must start with an upper case letter
in Tcl 9.

### [NOSUCHENCODING]

The referenced encoding is not available in Tcl 9.

### [OCTAL]

Tcl 9 expressions do not interpret strings of the form `0NNN` as octal
representation of integers. Replace with the `0oNNN` representation. Note
that the permissions argument or option for the `open` and `file attributes`
commands respectively will still accept the old octal notation but returned
values will use the newer octal notation.

The migration script limits its checks to use in expressions, (`expr`, `if`
etc.) as a generalized check generates too many false positives as
0-prefixed numeric strings are often used as plain string arguments.

### [STRINGISINT]

Unlike Tcl 8, the `string is integer` command will accept integers
that do not fit in 32-bits. Furthermore, the command will accept and
ignore `_` as a separator within numeric strings. Therefore any use
of the command should be checked that it is not used as a 32-bit range
check or for validation where the string should be strictly numeric.

### [TCLPKGVER]

Tcl 9 will not satisfy the Tcl version requirements included in a
`package require` or `package present` command. Verify that script will
work with Tcl 9 and change the referenced `package` invocation to permit
Tcl 9. This may be done be either removing version requirements, adding `9`
to the list of permitted versions, or terminating an existing version
requirement with a `-` to indicate higher versions are allowed, e.g.
`8.6-`.

### [RELATIVENS]

In Tcl 8, references to variables qualified with **relative** namespaces
were looked up in the global namespace as well. For example, a reference to
`ns2::var` from within the `::ns` namespace would search for
`::ns::ns2::var` and if not found, look for `::ns2::var` as well. This is no
longer the case in Tcl 9. If the `ns2` reference was with respect to the
global namespace, the reference needs to be explicitly qualified as
`::ns2::var`.

### [SOURCEENCODING]

The encoding for a sourced Tcl script not that expected. The expected
encoding is either one specified with the `-encoding` option or the default
`utf-8`. It is recommended that Tcl scripts be converted to UTF-8. If that
is not desirable for any reason, an `-encoding` option to the `source`
command needs to be added when sourcing those files.

In all cases, the suggested encoding is **only a guess** and should be
verified by other means. The referenced file should be converted as
appropriate. On Unix/Linux this can be done with the `iconv` utility which
is present in most distributions. It is also available for Windows as a
download from several sites.

### [TILDEPATH]

Tcl 9 does not do implicit tilde expansion in file paths. For example, Tcl 8
code such as

```
set fd [open ~/tclshrc.tcl]
```

will fail with a *no such file or directory* error.

Rewrite the code to do explicit expansion using
`file tildeexpand` or `file home`.

```
set fd [open [file tildeexpand ~/tclshrc.tcl]]
```

### [UNDECLARED]

In Tcl 8, writes within a namespace block (outside procs) to an unqualified
variable name that was not declared with `variable` would result in
overwriting of a global variable of the same name if one existed. This was
already a source of unintended modification of globals and deprecated. In
Tcl 9, the behavior has changed to not modify variables in the global
namespace. To remove ambiguities and compatibility issues, it is strongly
recommended to declare variables explicitly with `variable` or qualify
it with `::` depending on whether the intent was to modify a namespace
variable or a global.

### [UNKNOWNCOMMAND]

The command is not available in Tcl 9.

The `string bytelength` command is not present in Tcl 9.

The `case` command is not present in Tcl 9. The `switch` command can be
used in its place.

The subcommands `variable`, `vinfo` and `vdelete` of the `trace` command
are not present in Tcl 9. The `trace add variable`, `trace remove variable`
and `trace info variable` commands can be used in their place.

### [UNKNOWNVAR]

The variable is not available in Tcl 9.

The `tcl_platform(threaded)` variable is not present in Tcl 9. Use the
`tcl::pkgconfig get threaded` command instead.

## Limitations

Aside from false positives and false negatives, the static analyser does not
inspect methods and procs in thirdparty object-oriented frameworks like
XOTcl, NX or Itcl. The runtime analyzer will however catch many potential
incompatibilities when enabled in test suites using these frameworks.

## Credits

The static analyzer uses a custom version of Peter Spjuth's
[Nagelfar](https://nagelfar.sourceforge.net/index.html) application.
