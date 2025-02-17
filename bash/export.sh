#!/bin/bash

#(1) export.sh an ...
for accessionnumber in "$@"
do
#(2)Finds OT by qido
  qidoresp=$(curl -s "http://127.0.0.1:8080/dcm4chee-arc/aets/DCM4CHEE/rs/instances?00080050=$accessionnumber&00080060=OT")
  if (( ${#qidoresp} > 0)); then
  studydate=${qidoresp#*'00080020":{"vr":"DA","Value":["'}
  studydate=${studydate%%'"'*}
  reporter=${qidoresp#*'00080090":{"vr":"PN","Value":[{"Alphabetic":"'}
  reporter=${reporter%%'"'*}
  patientid=${qidoresp#*'00100020":{"vr":"SH","Value":["'}
  patientid=${patientid%%'"'*}
  patientpath="/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$reporter/$patientid"
#done dir
      mkdir -p "$patientpath"
      if [ -f "$patientpath/$accessionnumber" ]||[ -f "$patientpath/$accessionnumber.done" ]; then
          echo "· $patientpath/$accessionnumber"
      else
#qido
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
          curl -s "http://127.0.0.1:8080/dcm4chee-arc/aets/DCM4CHEE/wado?requestType=WADO&studyUID=$studyUID&seriesUID=$seriesUID&objectUID=$objectUID&contentType=application/dicom" | /Users/Shared/DICMxml2pdf/bash/DICMxml2pdf "$patientpath/$accessionnumber"
      fi

      for path in $( mdfind -onlyin /Volumes/IN/TEST/CLASSIFIED -name "$accessionnumber" ); do
           cp -Rn "$path" "$patientpath"
      done
           
      /usr/local/bin/storescu  -ll info 164.77.96.138 104 +sd +r +sp '*[0-9]' +rn -R +C -xe -aec RADIOIMAGEN "$patientpath"
          
   fi
done

