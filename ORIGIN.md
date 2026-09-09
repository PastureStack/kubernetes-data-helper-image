# Origin and Attribution

This repository preserves its complete pre-migration Git history. Commit `03bb3134958684af1ef9b1bc65ca9ad07d19131b` is the reviewed migration baseline, and the preserved history remains the authoritative record of authorship, dates, and changes. Private staging locations and personal namespaces are intentionally excluded from public repository content.

The maintenance image was created to replace the historical `busybox` data helper used by a legacy Kubernetes catalog while preserving its one-shot, successful-exit behavior. It was not published by the platform vendor, SUSE, or the Kubernetes project.

The PastureStack repository is:

- Repository: `PastureStack/kubernetes-data-helper-image`

The maintained image uses the pure numeric release `v0.1.2`. Earlier
non-numeric compatibility releases remain immutable historical evidence; their
qualifiers are intentionally not reused or advertised as current coordinates.

Historical names and image references may appear in this file, compatibility documentation, preserved Git history, and source attribution. They identify origins or compatibility targets and do not imply sponsorship or endorsement.

PastureStack is an independent community maintenance project. It is not affiliated with or endorsed by the historical platform vendor, SUSE, or the Kubernetes project.

The repository is licensed under Apache License 2.0. No upstream `NOTICE` file was present in the migration baseline, so this repository does not invent or synthesize one. The Ubuntu base image and its packages are separate third-party components governed by their respective terms.
