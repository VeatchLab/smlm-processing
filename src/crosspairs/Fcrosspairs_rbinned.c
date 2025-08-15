#include "mex.h"
#include "matrix.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdint.h>

#define OK 0
#define ERR_OVERFLOW 1

double sqrt();

void Fcrosspairs_rbinned(n1, x1, y1, t1, n2, x2, y2, t2, redges, nbins, taumin, taumax, rbinned, ignore_dr_0)
     /* inputs */
     int n1, n2;
     double *x1, *y1, *x2, *y2, *redges, *t1, *t2, taumin, taumax;
     /* outputs */
     int *rbinned, nbins, ignore_dr_0;
     
{
  int i, j, l, jleft, evenly_spaced, bin;
  double x1i, y1i, rmax, r2max, xleft, dx, dy, dx2, d2, dt, binwidth;
 
  rmax = redges[nbins];
  r2max = rmax * rmax;

  if(n1 == 0 || n2 == 0) 
    return;

  /* check if edges of histogram are evenly spaced */
  evenly_spaced = 1;
  binwidth = redges[1] - redges[0];
  mexPrintf("redges[0] = %f", redges[0]);
  mexPrintf("redges[nbins] = %f", redges[nbins]);
  for (i = 1; i < nbins; i++)
  {
      if ((redges[i+1] - redges[i]) != binwidth)
      {
          evenly_spaced = 0;
          break;
      }
  }
  mexPrintf("Evenly_spaced = %i", evenly_spaced);
  i = 0;
  while (i < n1) {

      /* Possibly check for matlab interrupt. */

      for (; i < n1; i++) {

          x1i = x1[i];
          y1i = y1[i];

          /* adjust starting position jleft */
          xleft = x1i - rmax;
          while ((x2[jleft] < xleft) && (jleft + 1 < n2))
              ++jleft;

          /* process from j=jleft until dx > rmax */
          for (j = jleft; j < n2; j++) {
              dx = x2[j] - x1i;
              dx2 = dx * dx;
              if (dx2 > r2max)
                  break;
              dy = y2[j] - y1i;
              d2 = dx2 + dy * dy;

              dt = t2[j] - t1[i];
              if (d2 <= r2max && taumin <= dt && dt <= taumax) {   
                  /* ignore d2 = 0 cases because these represent the same localizations?*/
                  if (d2 == 0 && ignore_dr_0)
                  {
                      continue;
                  }

                  /* if bins are of equal width we have a shortcut.*/
                  if (evenly_spaced)
                  {
                      bin = (int)((d2 - redges[0]) / binwidth);
                      if (bin == nbins)
                      {
                          rbinned[nbins - 1]++;
                      }
                      else
                      {
                          rbinned[bin]++;
                      }
                  }

                  else
			      {
				      for (l = 0; l < nbins; l++)
				      {
				          if (((redges[l] * redges[l]) <= d2) && (d2 <= (redges[l + 1] * redges[l + 1])))
				          /* increment count by 1 */
				          {
				              rbinned[l]++;
				              break;
				          }
				      }
                  }
              }
          }
      }
  }
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    int n1, n2;
    double *x1, *y1, *t1, *x2, *y2, *t2;
    double rmax, taumin, taumax, ignore_dr_0;
    double *redges;
    int *rbinned, nbins;
    int i;

    /* RHS args are:
     *  0   x1 // coords for first pp
     *  1   y1
     *  2   t1
     *  3   x2 // coords for second pp
     *  4   y2
     *  5   t2
     *  6   redges
     *  7   taumin
     *  8   taumax
     *  9   ignore_dr_0
     */

    /* LHS arg is:
     * 0 rbinned
     */

    n1 = mxGetNumberOfElements(prhs[0]);
    n2 = mxGetNumberOfElements(prhs[3]);

    x1 = (double *) mxGetPr(prhs[0]);
    y1 = (double *) mxGetPr(prhs[1]);
    t1 = (double *) mxGetPr(prhs[2]);
    x2 = (double *) mxGetPr(prhs[3]);
    y2 = (double *) mxGetPr(prhs[4]);
    t2 = (double *) mxGetPr(prhs[5]);

    redges = (double *) mxGetPr(prhs[6]);
    taumin = mxGetScalar(prhs[7]);
    taumax = mxGetScalar(prhs[8]);
    ignore_dr_0 = mxGetScalar(prhs[9]);

    nbins = mxGetNumberOfElements(prhs[6]) - 1;

    plhs[0] = mxCreateNumericMatrix(1, nbins, mxINT32_CLASS, mxREAL);
    rbinned = (int*)mxGetData(plhs[0]);
   
    Fcrosspairs_rbinned(n1, x1, y1, t1, n2, x2, y2, t2,
            redges, nbins, taumin, taumax, rbinned, ignore_dr_0);

}
  
