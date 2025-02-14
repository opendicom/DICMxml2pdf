#!/bin/bash
#$1 export aet
#$2 export ip
#$3 export port

DICMrepo=/Volumes/IN/TEST/CLASSIFIED
for accessionnumber in "$@"
do
    qidoresp=$(curl -s "http://127.0.0.1:8080/dcm4chee-arc/aets/DCM4CHEE/rs/instances?00080050=$accessionnumber&00080060=OT")
   if (( ${#qidoresp} > 0)); then
#studydate
      studydate=${qidoresp#*'00080020":{"vr":"DA","Value":["'}
      studydate=${studydate%%'"'*}
#patientid
      patientid=${qidoresp#*'00100020":{"vr":"SH","Value":["'}
      patientid=${patientid%%'"'*}
#done dir
      mkdir -p "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid"
if [ -f "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid/$accessionnumber.pdf.dcm" ];then #send pdf.dcm
         /usr/local/bin/storescu -i "$2" "$3" +sd +r +sp '*[0-9]' +rn -R +C -xe -aec "$1" "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid/$accessionnumber.pdf.dcm"

elif [ -f "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid/$accessionnumber.pdf.dcm.done" ]; then #pdf.dcm available
         #is there related studies to send?
         for path in $( mdfind -onlyin "$DICMrepo" -name "$accessionnumber" ); do
             /usr/local/bin/storescu -i "$2" "$3" +sd +r +sp '*[0-9]' +rn -R +C -xe -aec "$1" "$path"
         done
else #qido
#studyUID
          studyUID=${qidoresp#*'0020000D":{"vr":"UI","Value":["'}
          studyUID=${studyUID%%'"'*}
#seriesUID
          seriesUID=${qidoresp#*'0020000E":{"vr":"UI","Value":["'}
          seriesUID=${seriesUID%%'"'*}
#objectUID
          objectUID=${qidoresp#*'00080018":{"vr":"UI","Value":["'}
          objectUID=${objectUID%%'"'*}
#wado
          curl -s "http://127.0.0.1:8080/dcm4chee-arc/aets/DCM4CHEE/wado?requestType=WADO&studyUID=$studyUID&seriesUID=$seriesUID&objectUID=$objectUID&contentType=application/dicom" | /Users/Shared/DICMxml2pdf/bash/DICMxml2pdf "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid/$accessionnumber.pdf.dcm"
fi
   fi
done

