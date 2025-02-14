//
//  b64decoder.h
//  DICMxml2pdf
//
//  Created by jacquesfauquex on 2025-02-08.
//

#ifndef b64decoder_h
#define b64decoder_h

/*
 decodes the buffer i into the buffer o
 
 the initial offset of o may be inferior to the initial offsety of i within the SAME BUFFER (palimpseste).
 This is no problem since the output is linearly 3/4th in size of the input.
 
 decodes
 -    until a character other than ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/ is found
 - or until limit is reach
 
 the variables ilength and olength are adjusted. ilength ignores the eventual = or == in the end of the base64 buffer
 */
void b64d(const char *i, int *ii, char *o, int *oo, int limit);

#endif /* b64decoder_h */
