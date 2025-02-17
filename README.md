# DICMxml2pdf

For reports comunication enclosed cda and enclosed pdf are two very useful objects. They may be combined. The xml of the cda may contain a <nonXMLBody> element, which in turn contains a pdf ( or any other type of document ).

In Opendicom we prefer the enclosed cda and when we need to archive a pdf, we put it into an enclosed cda.

But there is a very frequent use case where a dicom client knows how to display an enclosed pdf but does not accept the enclosed cda. Our solution is DICMxml2pdf, which receives an enclosed cda which encapsulates a pdf and transforms it into enclosed pdf.

It was programmed in pure C but built with macos xcode 12.4 based on our enclosed cdas and with many tricks to work as fast as possible. It's a good stub for a more general portable, slower, solution.

We added to the project bash scripts  as examples of workflows using DICMxml2pdf
