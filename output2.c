#include <stdio.h>
#include "fclib.h"

int main() {
 int i,j,rows;
 writeString("Enter number of rows: ");
 readInt(d);
 for(i = 1; i <= rows; i++) 
{
 for(j = 1; j <= i; j++) 
{
 writeString("* ");
}

 writeString("\n");
}

 return 0;
 
}
