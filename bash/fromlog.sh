#!/bin/bash
log=$(cat "$1" | grep alvaro.trullenque)

#"00080050":{"vr":"SH","Value":["
declare token=""
while [[ "${#log}" -ne "${#token}" ]] ; do
   token=${log%%'{"00080005": {"vr":"CS","Value":["ISO_IR 192"]},"00400100": {"vr":"SQ","Value":[{"00400001":{"vr":"AE","Value":["'*}
   log=${log#*'{"00080005": {"vr":"CS","Value":["ISO_IR 192"]},"00400100": {"vr":"SQ","Value":[{"00400001":{"vr":"AE","Value":["'}
   if [ "${#token}" -gt 800 ] ; then
#studydate
      studydate=${token#*'00400002":{"vr":"DA","Value":["'}
      studydate=${studydate%%'"'*}
#patientid
      patientid=${token#*'00100020":{"vr":"LO","Value":["'}
      patientid=${patientid%%'"'*}
#accessionnumber
      accessionnumber=${token#*'00080050":{"vr":"SH","Value":["'}
      accessionnumber=${accessionnumber%%'"'*}
#done dir
      mkdir -p "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid"
if [ -f "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid/$accessionnumber.pdf.dcm" ]; then
         #send pdf.dcm
         /usr/local/bin/storescu -i "$2" "$3" +sd +r +sp '*[0-9]' +rn -R +C -xe -aec "$1" "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid/$accessionnumber.pdf.dcm"

elif [ -f "/Users/Shared/mwldicom/log/RADIOIMAGEN/$studydate/$patientid/$accessionnumber.pdf.dcm.done" ]; then #pdf.dcm available
         #is there related studies to send?
         for path in $( mdfind -onlyin "$DICMrepo" -name "$accessionnumber" ); do
             /usr/local/bin/storescu -i "$2" "$3" +sd +r +sp '*[0-9]' +rn -R +C -xe -aec "$1" "$path"
         done
else #qido
          qidoresp=$(curl -s "http://127.0.0.1:8080/dcm4chee-arc/aets/DCM4CHEE/rs/instances?00080050=$accessionnumber&00080060=OT")
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

