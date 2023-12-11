# OpenAny

macOS app and file launcher for simple scripting.

Launches, performs its job, then quits. No long-running processes. No clutter in your menu bar!

## Usage

Powered by the `openany://` URL scheme, you can launch apps and open files!

- `openany://app/com.apple.textedit` launches TextEdit via its bundle identifier.
- `openany://app/com.apple.textedit/view?path=/path/to/file.txt` opens `/path/to/file.txt` in TextEdit.
- `openany://app/com.apple.textedit/view?url=file:///path/to/file.txt` opens `/path/to/file.txt` in TextEdit, but using a `file://` URL instead of a path.
- `openany://file/open?path=/path/to/file.txt` opens `/path/to/file.txt` in your default editor of text files.
- `openany://file/open?url=file:///path/to/file.txt` opens `/path/to/file.txt` in your default editor of text files, but using a `file://` URL instead of a path.
- `openany://file/openwith/com.apple.textedit?path=/path/to/file.txt` opens `/path/to/file.txt` in TextEdit.
- `openany://file/openwith/com.apple.textedit?url=file:///path/to/file.txt` opens `/path/to/file.txt` in TextEdit, but using a `file://` URL instead of a path.
- `openany://app/com.apple.textedit/view?path=/path/to/file.txt` opens `/path/to/file.txt` in TextEdit.
- `openany://app/com.apple.textedit/view?url=file:///path/to/file.txt` opens `/path/to/file.txt` in TextEdit, but using a `file://` URL instead of a path.

> ⚠️ For apps, you need the bundle identifier. PR's welcome for lookup of application by name!

## Why `file://`?!

### Easy parsing reason

the `path=` query parameter works best for files without spaces or any other URL-escaped characters.

For all others, you're better off with a file URL.

### Drag and drop reason

If you drag files from Finder into some apps, they will insert the `file://` into text field. Could be a text editor, a comment field on a calendar event, a note-taking app, a chat window -- you name it. That's how dropping files on macOS can behave.

You can delete the `file://` part to get to the path, of course, but then you have all the URL-escpaed special characters (like `%20` instead of spaces).

It's less annoying to just use the URL by that point. So we do.

## Taxonomy

The URL scheme is comprised of components like this:

    openany://HOST/SUBJECT[/VERB[/OBJECT[?key1=value1[&key2=value2[...]]]]]

When the `HOST` acts as the subject, the pattern becomes: 

    openany://HOST/VERB[/OBJECT[?key1=value1[&key2=value2[...]]]]

The query parameters are called the URL's _payload._

### List of possible `HOST`s

- `app`: Launch an app, identified by `SUBJECT`. That's the bundle identifier.
- `file`: Open a file specified by the payload

### List of possible `SUBJECT` patterns

- For the `app` host:
    - The `SUBJECT` is the app's bundle ID. (Followed by a verb.)
- For the `file` host:
    - `openwith` (acting as `VERB` here), see below.

### List of possible `VERB`s

- For the `app` host:
    - Given a `BUNDLE_ID` as `SUBJECT`
      - (none): Launches the app. Alias ans shorthand to `launch`.
      - `launch`: `/app/BUNDLE_ID/launch`
      - `view`: `/app/BUNDLE_ID/view` opens a file, specified by the payload, in the app. Alias for `/file/openwith/BUNDLE_ID`.
- For the `file` host:
    - `openwith`: Open a file, specified by the payload, with the app being the `OBJECT`. Alias for `/app/BUNDLE_ID/view`. Example: `openany://file/openwith/com.apple.textedit?path=/path/to/file.txt` opens `/path/to/file.txt` in TextEdit.

### List of possible Payloads

Only used by file-related actions, the payload keys are:

- `path`: As in `?path=/path/to/file.txt`, using an absolute POSIX path. Most useful for simple paths without e.g. spaces.
- `url`: As in `?url=file:///path/to%20a%file/with%20spaces.txt`, using an absolute `file://` URL, e.g. to easil encode special characters.
