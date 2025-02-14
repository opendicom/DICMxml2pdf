#include <stdio.h>  //puts() printf() sprintf()
#include <stdbool.h>
#include <stdlib.h> //malloc()
#include <libgen.h> //basename()
#include <string.h>//for memcpy() strlen()

#include "pdf.h"
#include "base64.h"

//DICMxml2pdf out in
int main(int argc, const char * argv[]) {
   char *DICMbuf=NULL;
   DICMbuf=malloc(0x5000000);
   
   FILE *inFile = NULL;
   FILE *outfFile;
   //https://stackoverflow.com/questions/11168244/how-can-i-associate-a-stream-file-with-stdout
   switch (argc) {
         
      case 1:{                                    //stdin > DICMxml2pdf        > stdout
         outfFile=fopen("/dev/null", "w");
         inFile=freopen(NULL, "rb", stdin);
         setvbuf(stdin, NULL, _IOFBF, 0x5000000);
       } break;
         
      case 2:{                                    //stdin > DICMxml2pdf out
         outfFile=fopen(argv[1], "w");
         if (outfFile == NULL) return 2;
         inFile=freopen(NULL, "rb", stdin);
         setvbuf(stdin, NULL, _IOFBF, 0x5000000);
      } break;
         
      case 3:{                                    //        DICMxml2pdf in out
         outfFile=fopen(argv[1], "w");
         if (outfFile == NULL) return 3;
         inFile=freopen( argv[2], "rb", stdin);
         if (inFile == NULL) return 4;
      } break;
         
      default:
         return 5;
         break;
   }
   
   unsigned long DICMsize=fread(DICMbuf, 1, 0x5000000, stdin);
   if (inFile!=NULL) fclose(inFile);
   
   //DICM00020010 DICM00080016 change cda to pdf '.2' to '.1'
   DICMbuf[194]=0x31;
   DICMbuf[408]=0x31;
   
   //DICM00420011 xml document starts with '<' (0x3C)
   int DICMidx=1000;//no need to search the first 1000 bytes
   while (DICMbuf[DICMidx++] != 0x3C){}
   int DICM00420011valueidx=DICMidx-1;

   /*
    two types of xml:
    (1) <nonXMLBody><text mediaType="text/plain">
        when text is empty, there is no '4,'
    (2) <nonXMLBody><text mediaType="application/pdf">
        b64 is prefixed with '4,' (0x34,0x2C) and found between bytes 7500 and 10000
    */
   DICMidx+=6500;
   int base64StringLength;
   int decodedLength;
   while (DICMidx<10000)
   {
      while ((DICMbuf[DICMidx++] != 0x34)&&(DICMidx<10000)){};
      if (DICMbuf[DICMidx++]==0x2C) break;
   }
   if (DICMidx>9999)
   {
      char path[strlen(argv[2])];
      strcpy(path,argv[2]);
      char * filename=basename(path);
      char line[strlen(filename)+6];
      sprintf(line,"%s sin pdf",filename);
      copypdfplaceholder(
        line,
        DICMbuf+DICM00420011valueidx,
        &decodedLength
        );
   }
   else b64d(
        DICMbuf+DICMidx,
        &base64StringLength,
        DICMbuf+DICM00420011valueidx,
        &decodedLength,
        (int)(DICMsize - DICMidx - 16) //length of 42001200 text/xml
       );
   //00420011 length
   bool padding=decodedLength & 1;
   unsigned int padded=(unsigned int)decodedLength + padding;
   char * paddedpointer=(char *)&padded;
   //size starts at DICM00420011valueidx - 4
   DICMbuf[DICM00420011valueidx-4]=paddedpointer[0];
   DICMbuf[DICM00420011valueidx-3]=paddedpointer[1];
   DICMbuf[DICM00420011valueidx-2]=paddedpointer[2];
   DICMbuf[DICM00420011valueidx-1]=paddedpointer[3];
   
   unsigned long DICM00420012=DICM00420011valueidx+decodedLength;
   if (padding) DICMbuf[DICM00420012++]=0x00;
   
   //00420012 application/pdf
   DICMbuf[DICM00420012++]=0x42;
   DICMbuf[DICM00420012++]=0x00;
   DICMbuf[DICM00420012++]=0x12;
   DICMbuf[DICM00420012++]=0x00;
   DICMbuf[DICM00420012++]=0x4C;
   DICMbuf[DICM00420012++]=0x4F;
   DICMbuf[DICM00420012++]=0x10;
   DICMbuf[DICM00420012++]=0x00;
   DICMbuf[DICM00420012++]=0x61;
   DICMbuf[DICM00420012++]=0x70;
   DICMbuf[DICM00420012++]=0x70;
   DICMbuf[DICM00420012++]=0x6C;
   DICMbuf[DICM00420012++]=0x69;
   DICMbuf[DICM00420012++]=0x63;
   DICMbuf[DICM00420012++]=0x61;
   DICMbuf[DICM00420012++]=0x74;
   DICMbuf[DICM00420012++]=0x69;
   DICMbuf[DICM00420012++]=0x6F;
   DICMbuf[DICM00420012++]=0x6E;
   DICMbuf[DICM00420012++]=0x2F;
   DICMbuf[DICM00420012++]=0x70;
   DICMbuf[DICM00420012++]=0x64;
   DICMbuf[DICM00420012++]=0x66;
   DICMbuf[DICM00420012++]=0x20;
 
   if (fwrite(DICMbuf ,1, DICM00420011valueidx+padded+24, outfFile)!=DICM00420011valueidx+padded+24) {
      fclose(outfFile);
      return 6;
   }
   fclose(outfFile);

   return 0;
}
