# Migration tool for Tcl 9

This software is intended to help identify changes needed for porting
Tcl 8 scripts to Tcl 9. It has two modes of operation:

- a static analyzer based on Nagelfar that runs under both
  Tcl 8.6 and 9 logging warnings for potential incompatibilities.

- a runtime analyzer. This is intended to only run under Tcl 9.
  It attempts to fix up invalid code (e.g. tilde references) at
  run time allowing the program to continue to run but logs
  warnings to stderr.

It is expected the runtime analyzer is run only after fixing the
incompatibilities reported by the static analyzer.

## Static checks

The static analyzer may be run either with Tcl 8.6 or 9. However, the latter is
strongly suggested as the former will not detect encoding error conditions in
source files.

To run the static analyzer,

```
tclsh migrate.tcl check GLOBPAT ?GLOBPAT ...?
```

where `GLOBPAT` is a file glob pattern. Each file matching the pattern is
examined and warnings for any potential incompatibilities are printed to
standard output.


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

Note the main application file must have the correct encoding (UTF-8**.
As recommended, use the static analyzer first to verify this.

The runtime checks include

- Correct file encodings. In case of encoding failures, the correct encoding is
**guessed** to permit the program to continue and a warning printed to standard
error.

- Use of tildes in `open**, `file** and similar commands. These are expanded
appropriately allowing the program to run with a warning printed to standard
error.

## Warnings

Both tools may generate false positives. Any changes should be made keeping
that in mind.

The following warnings may be emitted by the tool:

**ENCODING** The encoding for the file was not that expected. The suggested
encoding is **only a guess**. The referenced file should be converted as
appropriate. Source files should generally be in UTF-8. For `open` the
generated message may be ignored if there is already a following call
to `fconfigure` to set the appropriate encoding. The runtime check
does not detect that.

**TILDE** Tcl 9 does not do implicit tilde expansion. Rewrite the code to
do explicit expansion with `file home` or `file tildeexpand**.

**OCTAL** Tcl 9 expressions do not interpret strings of the
form `0NNN` as octal representation of integers. Replace with the
`0oNNN** representation.

**NSVAR** In Tcl 8, references to variables qualified with **relative**
namespaces were looked up in the global namespace as well. For example,
a reference to `ns2::var` from within the `::ns` namespace would
search for `::ns::ns2::var` and if not found, look for `::ns2::var`
as well. This is no longer the case in Tcl 9. If the `ns2` reference
was with respect to the global namespace, the reference needs to
be explicitly qualified as `::ns2::var**.

**NOSUCHENCODING** The encoding is not available in Tcl 9.

## Credits

The static analyzer uses a custom version of Peter Spjuth's
[Nagelfar](https://nagelfar.sourceforge.net/index.html).
