#include <stdio.h>
#include <string.h>

main()
  {
   int x,len;
   char token[256];
   char *slash;
   while (scanf ("%s", token) != EOF)
      {
       if (token[0] == '/') 
           printf("%s", token);
       else {
             len = strlen(token);
	     for (x=len-1; x >= 0; x--) {
	           printf("%c", token[x]);
		  }
	    }
       printf ("\n");
      }
   return 0;
  }
