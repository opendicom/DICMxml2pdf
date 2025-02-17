# export.sh

(1) Receives one or more accession number args
(2) Finds OT by qido
(3) If it does not exist in 00080020/00080090/00100020 retrieves OT by wado url
(4) Transforms OT from DICMpdfcda to DICMpdf using DICMxml2pdf
(5) Writes result to 00080020/00080090
(6) mdfind corresponding images in repository
(7) copy them to 00080020/00080090/00100020
(8) storescu 00080020/00080090/00100020 to remote pacs

