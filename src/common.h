/*$Id: common.h,v 1.9 1994/05/26 13:47:18 berg Exp $*/

void
 shexec P((const char*const*argv)),
 detab P((char*p)),
 ultstr P((int minwidth,unsigned long val,char*dest));
char
 *skpspace P((const char*chp));
int
 waitfor Q((const pid_t pid)),
 strnIcmp P((const char*a,const char*b,size_t l));

#ifdef NOstrcspn
int
 strcspn P((const char*const whole,const char*const sub));
#endif

#define LENoffset	(TABWIDTH*LENtSTOP)
#define MAXfoldlen	(LENoffset-STRLEN(sfolder)-1)

#define NO_PROCESS	(-256)
