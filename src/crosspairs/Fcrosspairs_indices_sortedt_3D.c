
#include "mex.h"
#include <stdlib.h>
#include <string.h>

#define OK 0
#define ERR_OVERFLOW 1

double sqrt();

void Fcrosspairs_indices_sortedt(n1, x1, y1, z1, t1, n2, x2, y2, z2, t2, rmax, taumin, taumax, noutmax, 
	      nout, iout, jout, 
	      status)
     /* inputs */
     int n1, n2, *noutmax;
     double *x1, *y1, *z1, *x2, *y2, *z2, *t1, *t2, rmax, taumin, taumax;
     /* outputs */
     int *nout, **iout, **jout;
     int *status;
{
  int k, kmax, i, j, jfirst; /* note points are ordered by t, not x */
  double x1i, y1i, z1i, t1i, r2max, tfirst, dx, dy, dz, dx2, d2, dt;
 
  r2max = rmax * rmax;
 
  *status = OK;
  *nout = 0;
  k = 0;   /* k is the next available storage location 
              and also the current length of the list */
  kmax = *noutmax;

  if(n1 == 0 || n2 == 0) 
    return;

  jfirst = 0;
  
  i = 0;

  for (; i < n1; i++) {

   x1i = x1[i];
   y1i = y1[i];
   z1i = z1[i];
   t1i = t1[i];

   /* adjust starting position jfirst */
   tfirst = t1i + taumin;
   while ((t2[jfirst] < tfirst) && (jfirst + 1 < n2))
	++jfirst;

   /* process from j=jfirst until dt > taumax */
   for (j = jfirst; j < n2; j++) {
	dt = t2[j] - t1i;
	if (dt > taumax)
	 break;
    if (dt < taumin) /* happens when i1 + taumin > n1 */
     continue;

	dx = x2[j] - x1i;
	dx2 = dx * dx;
	if (dx2 <= r2max) {
	 dy = y2[j] - y1i;
     dz = z2[j] - z1i;
     d2 = dx2 + dy * dy + dz * dz;
	 if (d2 <= r2max) {
	  /* add this (i, j) pair to output */
	  if (k >= kmax) {
	   (*noutmax) *= 2;
	   kmax *= 2;
	   if (kmax >= 200000000)
	   {
		*nout = k;
		*status = ERR_OVERFLOW;
		return;
	   }

	   /* Allocate more memory.*/
	   *iout = realloc(*iout, kmax * sizeof(int));
	   *jout = realloc(*jout, kmax * sizeof(int));
	  }

	  (*iout)[k] = i + 1;
	  (*jout)[k] = j + 1;

	  ++k;
	 }
	}
   }
  }
  *nout = k;
}


void mexFunction(int nlhs, mxArray* plhs[],
    int nrhs, const mxArray* prhs[])
{
    /* inputs */
    int n1, n2, *noutmax;
    double *x1, *y1, *z1, *x2, *y2, *z2, rmax, *t1, *t2, taumin, taumax;
    /* outputs */
    int *nout, *iout, *jout;
    int *status;

    /* RHS args are:
     *  0   x1 // coords for first pp
     *  1   y1
     *  2   z1
     *  3   t1
     *  4   x2 // coords for second pp
     *  5   y2
     *  6   z2
     *  7   t2
     *  8   rmax
     *  9   taumin
     *  10   taumax
     */

     /* LHS args are:
      * 0,1    iout, jout
      * 2    optional error
      */

    /* Check for proper number of arguments. */
    if (nrhs != 11) {
        mexErrMsgIdAndTxt("MATLAB:timestwo:invalidNumInputs",
            "11 inputs required.");
    }
    else if (nlhs > 3) {
        mexErrMsgIdAndTxt("MATLAB:timestwo:maxlhs",
            "Too many output arguments.");
    }

    /* Read in inputs. */
    n1 = mxGetNumberOfElements(prhs[0]);
    n2 = mxGetNumberOfElements(prhs[4]);

    x1 = (double*)mxGetPr(prhs[0]);
    y1 = (double*)mxGetPr(prhs[1]);
    z1 = (double*)mxGetPr(prhs[2]);
    t1 = (double*)mxGetPr(prhs[3]);
    x2 = (double*)mxGetPr(prhs[4]);
    y2 = (double*)mxGetPr(prhs[5]);
    z2 = (double*)mxGetPr(prhs[6]);
    t2 = (double*)mxGetPr(prhs[7]);

    rmax = mxGetScalar(prhs[8]);
    taumin = mxGetScalar(prhs[9]);
    taumax = mxGetScalar(prhs[10]);
    
    /* Make an initial guess for noutmax. Not sure how best to go about this.*/
    int noutmax_guess = (n1 / 100) * (n2 / 100) / 400 * (rmax) + 1000;
    noutmax = (int*)malloc(sizeof(int));
    *noutmax = noutmax_guess;

    /* Dynamically allocate memory to outputs. */
    nout = (int*)malloc(sizeof(int));
    status = (int*)malloc(sizeof(int));
    iout = (int*)malloc(noutmax_guess * sizeof(int));
    jout = (int*)malloc(noutmax_guess * sizeof(int));

    /* Call the C subroutine. */
    Fcrosspairs_indices_sortedt(n1, x1, y1, z1, t1, n2, x2, y2, z2, t2, rmax, noutmax, taumin, taumax,
        nout, &iout, &jout,
        status);
    
    /* Create matrices for the return arguments. */
    plhs[0] = mxCreateNumericMatrix(*nout, 1, mxINT32_CLASS, mxREAL);
    int *out1 = (int*)mxGetData(plhs[0]);
    memcpy(out1, iout, (*nout) * sizeof(int));

    plhs[1] = mxCreateNumericMatrix(*nout, 1, mxINT32_CLASS, mxREAL);
    int* out2 = (int*)mxGetData(plhs[1]);
    memcpy(out2, jout, (*nout) * sizeof(int));

    plhs[2] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    int* out3 = (int*)mxGetData(plhs[2]);
    memcpy(out3, status, sizeof(int));

    /* Free the memory we allocated with malloc. */
    free(jout);
    free(iout);
    free(status);
    free(nout);
    free(noutmax);

}


