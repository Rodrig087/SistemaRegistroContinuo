#include <stdio.h>
void main (void)
{
  FILE *fp;
  int value;
  fp = fopen ("/home/pi/Ejemplos/PruebaArchivo/output.txt", "ab");
  if (fp)
  {
    fprintf(fp, "\n", value);
    for (value=0; value<10; value++)
    {
      fprintf(fp, "%d ", value);
    }
    fclose (fp);
  }
}
