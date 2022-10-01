#include "zls_fitpoly.h"

    //#include "zls_expressions.h"

#define SQR(x) ((x)*(x))

void nrerror(char error_text[]);
void nrerror(char error_text[]){
    //printf("Singular Matrix run-time error...\n");
    //printf("%s\n",error_text);
}

void FitNGauss(Real x, Real * ai, Real *y, Real *dyda, Integer m)
{
	Integer i;
	Real fac,ex,arg;
    // fit m/3 gaussians, m must be a multiple of 3, 3 coeffs per gaussian
    // 0 = Peak, 1 = centre, 2 = width
	*y=0.0;
	for (i=0;i<m;i+=3) {
        // gaussian
		arg=(x-ai[i+1])/ai[i+2];
		ex=exp(-arg*arg);
		*y += ai[i]*ex;
        // derivatives
		fac=ai[i]*ex*2.0*arg;
		dyda[i]=ex;
		dyda[i+1]=fac/ai[i+2];
		dyda[i+2]=fac*arg/ai[i+2];
	}

}

void FitGaussPoly(Real x, Real * ai, Real *y, Real *dyda, Integer m)
{
	Integer i;
	Real fac,ex,arg;

    // fit 1 gaussian + cont, m must be a minimum of 3, 3 coeffs per gaussian
    // remaining are polynomial background
    // 0 = Peak, 1 = centre, 2 = width, 3 = constant, 4 x , 5 x^2

	*y      = 0.0;

    // gaussian

    arg     = (x-ai[1])/ai[2];
    ex      = exp(-arg*arg);
    *y     += ai[0]*ex;

    // derivatives wrt ai

    fac     = ai[0]*ex*2.0*arg;
    dyda[0] = ex;
    dyda[1] = fac/ai[2];
    dyda[2] = fac*arg/ai[2];

    Real lx = 1.0;
    for (i=3;i<m;i++) {
        *y      += ai[i]*lx;  
  		dyda[i]  = lx;
        lx      *= (x-ai[1]);
    }
    

}

void FitPolynomial (Real x, Real * ai, Integer  m){
    Integer i;

    ai[0] = 1.0;

    for (i = 1; i <  m; i++ )
        ai[i] = ai[i - 1] * x;

};

void FitLegendre (Real x, Real * ai, Integer m){
	Integer i;
	Real twox,f2,f1,d;
    
	ai[0] = 1.0;
	ai[1] = x;
	if (m > 2) {
		twox = x+x;
		f2   = x;
        d = 1.0;
		for (i = 2; i < m; i++) {
			f1    = d; d += 1.0;
			f2   += twox;
			ai[i] = (f2*ai[i-1]-f1*ai[i-2])/d;
		}
	}
};

void FitCheby (Real x, Real * ai, Integer  m){
    Integer i;
    Real twox;
    ai[0] = 1.0;
    ai[1] = x;
    if (m > 2) {
		twox = x+x;
        for (i = 2; i< m; i++)
            ai[i] = (twox * ai[i - 1]) - ai[i - 2];
    };
};

void FitHarmonic (Real x, Real * ai, Integer  m){
    Integer i;
    ai[0] = 1.0;
    for (i = 1; i< m; i++ ) 
        ai[i] = ai[i - 1] / x;
};

void FitHarmonicPlusLog (Real x, Real * ai, Integer  m){
    Integer i;
    ai[0] = 1.0;
    for (i = 1; i< (m-1); i++ ) 
        ai[i] = ai[i - 1] / x;
    ai[m-1] = log(x);
};

#define SWAP(a,b) {swap=(a);(a)=(b);(b)=swap;}
void covsrt(Real  **covar, int ma, int ia[], int mfit);
void covsrt(Real  **covar, int ma, int ia[], int mfit)
{
	int i,j,k;
	Real  swap;
    
	for (i=mfit;i<ma;i++)
		for (j=0;j<=i;j++) 
            covar[i][j]=covar[j][i]=0.0;
    
	k=mfit;
	for (j=(ma-1);j>=0;j--) {
		if (ia[j]==kFitFreeCoeff) {
            
            k--;
            
			for (i=0;i<ma;i++) {
                SWAP(covar[i][k],covar[i][j]);
            }
            
            for (i=0;i<ma;i++) { 
                SWAP(covar[k][i],covar[j][i]);
            }
            
		}
	}
}

int gaussj(Real  **a, int n, Real  *b);
int gaussj(Real  **a, int n, Real  *b) {
    
    int err = 0;

    if (n<=0) return -1;
    
	int i,j,k,l,ll;
	int icol = 0;
    int irow = 0;

	Real  big,dum,pivinv,swap;
    
    Integer indxc[n+1];
    Integer indxr[n+1];
    Integer ipiv [n+1];
    
    for (i=0;i<n;i++) {
        if ( isnan(b[i]) ) return -3;
        for (j=0;j<n;j++) {
            if ( isnan(a[i][j]) ) return -3;
        }
    }
    
	for (j=0;j<=n;j++) {
        indxc[j]=0;
        indxr[j]=0;
        ipiv[j]=0;
    }
    
    for (i=0;i<n;i++) {
        
		big=0.0;
		for (j=0;j<n;j++){
			if (ipiv[j] != 1){
				for (k=0;k<n;k++) {
					if (ipiv[k] == 0) {
						if (fabs(a[j][k]) >= big) {
							big=fabs(a[j][k]);
							irow=j;
							icol=k;
						}
					} else if (ipiv[k] > 1) { 
                        nrerror("gaussj: Singular Matrix-1"); 
                        return -1;
                    }
				}; // k
            }; //ipiv
        }; // j
        
        ++(ipiv[icol]);
        
		if (irow != icol) {
			for (l=0;l<n;l++) SWAP(a[irow][l],a[icol][l]);
            SWAP(b[irow],b[icol]);
		};
        
        indxr[i]=irow;
        indxc[i]=icol;
        
        if (a[icol][icol] == 0.0) {
            nrerror("gaussj: Singular Matrix-2"); 
            return -2;
        }
        
        pivinv=1.0/a[icol][icol];
        a[icol][icol]=1.0;
        
        for (l=0;l<n;l++) a[icol][l] *= pivinv;
        b[icol] *= pivinv;
        
        for (ll=0;ll<n;ll++){
            if (ll != icol) {
                dum=a[ll][icol];
                a[ll][icol]=0.0;
                for (l=0;l<n;l++) a[ll][l] -= a[icol][l]*dum;
                b[ll] -= b[icol]*dum;
            }; 
        }; // ll,l
        
        
    }; // i
    
    for (l=(n-1);l>=0;l--) {
        if (indxr[l] != indxc[l]){
            for (k=0;k<n;k++){
                SWAP(a[k][indxr[l]],a[k][indxc[l]]);
            };
        };
    };
    
    return err;
    
}
#undef SWAP

int lfit(Real  x[], Real  y[], Real  sig2i[], int ndat, Real  a[], int ia[],
          int ma, Real  **covar, Real  *chisq, void (*funcs)(Real , Real *, int));
int lfit(Real  x[], Real  y[], Real  sig2i[], int ndat, Real  a[], int ia[],
          int ma, Real  **covar, Real  *chisq, void (*funcs)(Real , Real *, int))
{
    int err = 0;
	int i,j,k,l,m,mfit=0;
	Real  ym,wt,sum;//,sig2i;
    
	Real beta[ma];
	Real afunc[ma];
    
	for (j=0;j<ma;j++) if (ia[j]==kFitFreeCoeff) mfit++;
	if (mfit == 0) nrerror("lfit: no parameters to be fitted");
	for (j=0;j<mfit;j++) {
		for (k=0;k<mfit;k++) covar[j][k]=0.0;
		beta[j]=0.0;
	};
    
	for (i=0;i<ndat;i++) {
        
		(*funcs)(x[i],afunc,ma);
        
		ym=y[i];
		if (mfit < ma) {
			for (j=0;j<ma;j++)
				if (ia[j]==kFitFixedCoeff) ym -= a[j]*afunc[j];
		}
		//sig2i=1.0/SQR(sig[i]);
        j = 0;
		for (l=0;l<ma;l++) {
			if (ia[l]==kFitFreeCoeff) {
                
				wt=afunc[l]*sig2i[i];
                
                k = 0;
				for ( m=0 ; m<=l; m++){
					if (ia[m]==kFitFreeCoeff) {
                        covar[j][k++] += wt*afunc[m];
                    };
                };
                
				beta[j++] += ym*wt;
                
			}
		}
	}
    
	for (j=1;j<mfit;j++)
		for (k=0;k<j;k++)
			covar[k][j]=covar[j][k];
    
	err = gaussj(covar,mfit,beta);
    if ( err != 0) {
        return err;
    }
    
    j = 0;
	for ( l=0; l<ma; l++ )
		if (ia[l]==kFitFreeCoeff) a[l]=beta[j++];
    
	*chisq=0.0;
    
	for (i=0;i<ndat;i++) {
		(*funcs)(x[i],afunc,ma);
        
        sum = 0.0;
		for ( j=0; j<ma; j++) 
            sum += a[j]*afunc[j];
        
        Real dy=y[i]-sum;

		*chisq += dy*dy*sig2i[i];
        
	}
    
	covsrt(covar,ma,ia,mfit);
    return err;
}

int LinearFitPoly (Q1DArr  xq, Q1DArr yq, Integer n, 
                   Q1DArr yerr, Integer errormode,
                   I1DArr fai, Q1DArr ai, Q1DArr sai, Integer nterms, 
                   Integer fit, Real * rchi){
    int err = 0;
	int i;
	Real  chisq = 0.0;
    
    Q2DArr covar;
    zls_NewQuantity2DArr(&covar, nterms, nterms);
    
    Q1DArr sig;
    zls_NewQuantity1DArr(&sig, n);
    
    if ( yerr == NULL){
        for (i=0;i<n;i++) {
            sig[i] = 0.01*sqrt(fabs(yq[i]));
        }
    } else {
        for (i=0;i<n;i++) {
            sig[i] = fabs(yerr[i]);
        }
    }
   
    Q1DArr sig2i;
    zls_NewQuantity1DArr(&sig2i, n);
    if ( yerr == NULL){
        if (errormode == kFitSqrtWeighting){
            for (i=0;i<n;i++) {
                if (yq[i] != 0.0){
                    sig2i[i] = 1.0/fabs(yq[i]); // 1/sqrt(y)^2
                } else {
                    sig2i[i] = 1.0;
                }
            }
        } else { // kFitNoErrorWeighting, or err not known
            for (i=0;i<n;i++) {
                sig2i[i] = 1.0;
            }
        }
    } else { // kFitYErrWeighting
        for (i=0;i<n;i++) {
            sig2i[i] = 1.0/(yerr[i]*yerr[i]);
        }
    }

    
    switch ( fit){
        default:
        case kFitFNPower: 
            err = lfit(xq,yq,sig2i,n,ai,fai,nterms,covar,&chisq, FitPolynomial);
            break;
        case kFitFNLegendre: 
            err = lfit(xq,yq,sig2i,n,ai,fai,nterms,covar,&chisq, FitLegendre);
            break;
        case kFitFNCheby: 
            err = lfit(xq,yq,sig2i,n,ai,fai,nterms,covar,&chisq, FitCheby);
            break;
        case kFitFNHarmonic: 
            err = lfit(xq,yq,sig2i,n,ai,fai,nterms,covar,&chisq, FitHarmonic);
            break;
        case kFitFNHarmonicLog: 
            err = lfit(xq,yq,sig2i,n,ai,fai,nterms,covar,&chisq, FitHarmonicPlusLog);
            break;
    }; 
    
    if (sai)  for (i=0;i<nterms;i++) sai[i] = covar[i][i];
    
    if (rchi != NULL) *rchi = chisq;
    
    zls_DisposeQuantity1DArr(sig);
    zls_DisposeQuantity2DArr(covar);
    
    return(err);
    
}

Real gasdev(long *idum);

void svdvar(Real **v, Integer ma, Real w[], Real **cvm);

void svdfit( Q1DArr x, Q1DArr y, Q1DArr sig, Integer ndata, 
            Q1DArr a, Integer ma,
            Q2DArr u, Q2DArr v, Q1DArr w, Real *chisq,
            void (*funcs)(Real, Real *, Integer));



void svdvar(Real **v, Integer ma, Real w[], Real **cvm)
{
	int k,j,i;
	Real sum;
    
	Real wti[ma];
	for (i=0;i<ma;i++) {
		wti[i]=0.0;
		if (w[i]) wti[i]=1.0/(w[i]*w[i]);
	}
	for (i=0;i<ma;i++) {
		for (j=0;j<=i;j++) {
			for (sum=0.0,k=0;k<ma;k++) sum += v[k][i]*v[k][j]*wti[k];
			cvm[j][i]=cvm[i][j]=sum;
		}
	}
    
}

#define IA 16807
#define IM 2147483647
#define AM (1.0/IM)
#define IQ 127773
#define IR 2836
#define NTAB 32
#define NDIV (1+(IM-1)/NTAB)
#define EPS 1.2e-7
#define RNMX (1.0-EPS)

float ran1(long *idum);
float ran1(long *idum)
{
	long j;
	long k;
	static long iy=0;
	static long iv[NTAB];
	float temp;
    
	if (*idum <= 0 || !iy) {
		if (-(*idum) < 1) *idum=1;
		else *idum = -(*idum);
		for (j=NTAB+7;j>=0;j--) {
			k=(*idum)/IQ;
			*idum=IA*(*idum-k*IQ)-IR*k;
			if (*idum < 0) *idum += IM;
			if (j < NTAB) iv[j] = *idum;
		}
		iy=iv[0];
	}
	k=(*idum)/IQ;
	*idum=IA*(*idum-k*IQ)-IR*k;
	if (*idum < 0) *idum += IM;
	j=iy/NDIV;
	iy=iv[j];
	iv[j] = *idum;
	if ((temp=AM*iy) > RNMX) return RNMX;
	else return temp;
}
#undef IA
#undef IM
#undef AM
#undef IQ
#undef IR
#undef NTAB
#undef NDIV
#undef EPS
#undef RNMX


Real gasdev(long *idum)
{
	float ran1(long *idum);
	static int iset=0;
	static float gset;
	float fac,rsq,v1,v2;
    
	if  (iset == 0) {
		do {
			v1=2.0*ran1(idum)-1.0;
			v2=2.0*ran1(idum)-1.0;
			rsq=v1*v1+v2*v2;
		} while (rsq >= 1.0 || rsq == 0.0);
		fac=sqrt(-2.0*log(rsq)/rsq);
		gset=v1*fac;
		iset=1;
		return v2*fac;
	} else {
		iset=0;
		return gset;
	}
}


Real pythag(Real a, Real b);
Real pythag(Real a, Real b)
{
	Real absa,absb;
	absa=fabs(a);
	absb=fabs(b);
	if (absa > absb) return absa*sqrt(1.0+SQR(absb/absa));
	else return (absb == 0.0 ? 0.0 : absb*sqrt(1.0+SQR(absa/absb)));
}

#define SIGN(a,b) ((b) >= 0.0 ? fabs(a) : -fabs(a))

static Integer iminarg1,iminarg2;
#define IMIN(a,b) (iminarg1=(a),iminarg2=(b),(iminarg1) < (iminarg2) ?\
(iminarg1) : (iminarg2))

static Real dmaxarg1,dmaxarg2;
#define DMAX(a,b) (dmaxarg1=(a),dmaxarg2=(b),(dmaxarg1) > (dmaxarg2) ?\
(dmaxarg1) : (dmaxarg2))

void svdcmp(Q2DArr a, Integer m, Integer n, Q1DArr w, Q2DArr v);
void svdcmp(Q2DArr a, Integer m, Integer n, Q1DArr w, Q2DArr v)
{
    
	Integer flag, i,j,k,its,jj,l,nm;
	Real anorm,c,f,g,h,s,scale,x,y,z;
    
	Real rv1[(Counter)n];
    
    nm=0;

    if (( m < 1) || (n < 1) ) return;
	
	g=scale=anorm=0.0;
	for (i=0;i<n;i++) {
		l=i+1;
		rv1[i]=scale*g;
		g=s=scale=0.0;
		if (i < m) {
			for (k=i;k<m;k++) scale += fabs(a[i][k]);
			if (scale) {
				for (k=i;k<m;k++) {
					a[i][k] /= scale;
					s += a[i][k]*a[i][k];
				}
				f=a[i][i];
				g = -SIGN(sqrt(s),f);
				h=f*g-s;
				a[i][i]=f-g;
				for (j=l;j<n;j++) {
					for (s=0.0,k=i;k<m;k++) s += a[i][k]*a[j][k];
					f=s/h;
					for (k=i;k<m;k++) a[j][k] += f*a[i][k];
				}
				for (k=i;k<m;k++) a[i][k] *= scale;
			}
		}
		w[i]=scale *g;
        
		g=s=scale=0.0;
		if (i < m && i != (n-1)) {
			for (k=l;k<n;k++) scale += fabs(a[k][i]);
			if (scale) {
				for (k=l;k<n;k++) {
					a[k][i] /= scale;
					s += a[k][i]*a[k][i];
				}
				f=a[l][i];
				g = -SIGN(sqrt(s),f);
				h=f*g-s;
				a[l][i]=f-g;
				for (k=l;k<n;k++) rv1[k]=a[k][i]/h;
				for (j=l;j<m;j++) {
					for (s=0.0,k=l;k<n;k++) s += a[k][j]*a[k][i];
					for (k=l;k<n;k++) a[k][j] += s*rv1[k];
				}
				for (k=l;k<n;k++) a[k][i] *= scale;
			}
		}
		anorm=DMAX(anorm,(fabs(w[i])+fabs(rv1[i])));
	}
	
    for (i=(n-1);i>=0;i--) {
		if (i < (n-1)) {
			if (g) {
				for (j=l;j<n;j++)
					v[i][j]=(a[j][i]/a[l][i])/g;
				for (j=l;j<n;j++) {
					for (s=0.0,k=l;k<n;k++) s += a[k][i]*v[j][k];
					for (k=l;k<n;k++) v[j][k] += s*v[i][k];
				}
			}
			for (j=l;j<n;j++) v[j][i]=v[i][j]=0.0;
		}
		v[i][i]=1.0;
		g=rv1[i];
		l=i;
	}
    
	for (i=IMIN(m,n)-1;i>=0;i--) {
		l=i+1;
		g=w[i];
		for (j=l;j<n;j++) a[j][i]=0.0;
		if (g) {
			g=1.0/g;
			for (j=l;j<n;j++) {
				for (s=0.0,k=l;k<m;k++) s += a[i][k]*a[j][k];
				f=(s/a[i][i])*g;
				for (k=i;k<m;k++) a[j][k] += f*a[i][k];
			}
			for (j=i;j<m;j++) a[i][j] *= g;
		} else for (j=i;j<m;j++) a[i][j]=0.0;
		++a[i][i];
	}
    
	for (k=n-1;k>=0;k--) {
		for (its=1;its<=30;its++) {
			flag=1;
			for (l=k;l>0;l--) {
				nm=l-1;
				if ((Real)(fabs(rv1[l])+anorm) == (Real)anorm) {
					flag=0;
					break;
				}
				if ((Real)(fabs(w[nm])+anorm) == (Real)anorm) break;
			}
			if (flag) {
				c=0.0;
				s=1.0;
				for (i=l;i<=k;i++) {
                    f=s*rv1[i];
					rv1[i]=c*rv1[i];
					if ((Real)(fabs(f)+anorm) == (Real)anorm) break;
					g=w[i];
					h=pythag(f,g);
					w[i]=h;
					h=1.0/h;
					c =  g*h;
					s = -f*h;
					for (j=0;j<m;j++) {
						y=a[nm][j];
						z=a[i][j];
						a[nm][j]=y*c+z*s;
						a[i][j]=z*c-y*s;
					}
				}
                
			}
			z=w[k];
            
            //printf("its l k wk: %d %d %d %d %12.6f \n",its, l, k, nm, w[k]);
            
			if (l == k) {
				if (z < 0.0) {
					w[k] = -z;
					for (j=0;j<n;j++) v[k][j] = -v[k][j];
				}
				break;
			}
            
			if (its == 30) nrerror("no convergence in 30 svdcmp iterations");
            
			x=w[l];
			nm=k-1;
			y=w[nm];
			g=rv1[nm];
			h=rv1[k];
			f=((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y);
			g=pythag(f,1.0);
			f=((x-z)*(x+z)+h*((y/(f+SIGN(g,f)))-h))/x;
			c=s=1.0;
            //printf("2 its l k nm f g h: %d %d %d %d %12.6f %12.6f %12.6f \n",its, l, k, nm,f,g,h);
            
            
			for (j=l;j<=nm;j++) {
				i=j+1;
				g=rv1[i];
				y=w[i];
				h=s*g;
				g=c*g;
				z=pythag(f,h);
				rv1[j]=z;
				c=f/z;
				s=h/z;
				f=x*c+g*s;
				g = g*c-x*s;
				h=y*s;
				y *= c;
				for (jj=0;jj<n;jj++) {
					x=v[j][jj];
					z=v[i][jj];
					v[j][jj]=x*c+z*s;
					v[i][jj]=z*c-x*s;
				}
				z=pythag(f,h);
				w[j]=z;
				if (z) {
					z=1.0/z;
					c=f*z;
					s=h*z;
				}
				f=c*g+s*y;
				x=c*y-s*g;
				for (jj=0;jj<m;jj++) {
					y=a[j][jj];
					z=a[i][jj];
					a[j][jj]=y*c+z*s;
					a[i][jj]=z*c-y*s;
				}
			}
			rv1[l]=0.0;
			rv1[k]=f;
			w[k]=x;
		}
	}
    
}


void svbksb(Q2DArr u, Q1DArr w, Q2DArr v, Integer ndata, Integer nterms, Q1DArr b, Q1DArr x);
void svbksb(Q2DArr u, Q1DArr w, Q2DArr v, Integer ndata, Integer nterms, Q1DArr b, Q1DArr x)
{
	Integer jj,j,i;
	Real s;
    
	Real tmp[nterms];
    
	for (j=0;j<nterms;j++) {
		s=0.0;
		if (w[j]) {
			for (i=0;i<ndata;i++) s += u[j][i]*b[i];
			s /= w[j];
		}
		tmp[j]=s;
	}
	for (j=0;j<nterms;j++) {
		s=0.0;
		for (jj=0;jj<nterms;jj++) s += v[jj][j]*tmp[jj];
		x[j]=s;
	}
    
}


#define TOL 1.0e-5

void svdfit( Q1DArr x, Q1DArr y, Q1DArr sig, Integer ndata, 
            Q1DArr a, Integer ma,
            Q2DArr u, Q2DArr v, Q1DArr w, Real *chisq,
            void (*funcs)(Real, Real *, Integer))
{
    
	int j,i;
	float wmax,tmp,thresh,sum;
	Real b[(Counter)ndata];
	Real afunc[ma];
	for (i=0;i<ndata;i++) {
		(*funcs)(x[i],afunc,ma);
		tmp=1.0/sig[i];
		for (j=0;j<ma;j++) u[j][i]=afunc[j]*tmp;
		b[i]=y[i]*tmp;
	}
	svdcmp(u,ndata,ma,w,v);
	wmax=0.0;
	for (j=0;j<ma;j++)
		if (w[j] > wmax) wmax=w[j];
	thresh=TOL*wmax;
	for (j=0;j<ma;j++)
		if (w[j] < thresh) w[j]=0.0;
	svbksb(u,w,v,ndata,ma,b,a);
	*chisq=0.0;
	for (i=0;i<ndata;i++) {
		(*funcs)(x[i],afunc,ma);
		for (sum=0.0,j=0;j<ma;j++) sum += a[j]*afunc[j];
		*chisq += (tmp=(y[i]-sum)/sig[i],tmp*tmp);
	}
    
}
#undef TOL

int SVDFitPoly (Q1DArr xq, Q1DArr yq, Integer n, 
                Q1DArr ai, Integer nterms, 
                Integer fit, Real * rchi){
    
	int i;
    Real  chisq;
    Q1DArr sig;
    zls_NewQuantity1DArr(&sig, n);
    
    Q2DArr u;
    Q2DArr v;
    Q1DArr w;
    
    zls_NewQuantity2DArr( &u, nterms, n );
    zls_NewQuantity2DArr( &v, nterms, nterms );
    zls_NewQuantity1DArr( &w, nterms );
    
    
	for (i=0;i<n;i++) {
		sig[i] = 0.1;
	}
    
    switch ( fit){
        default:
        case kFitFNPower: 
            svdfit(xq,yq,sig,n,ai,nterms,
                   u, v, w,
                   &chisq, FitPolynomial);
            break;
        case kFitFNLegendre: 
            svdfit(xq,yq,sig,n,ai,nterms,
                   u, v, w,
                   &chisq, FitLegendre);
            break;
        case kFitFNCheby: 
            svdfit(xq,yq,sig,n,ai,nterms,
                   u, v, w,
                   &chisq, FitCheby);
            break;
        case kFitFNHarmonic: 
            svdfit(xq,yq,sig,n,ai,nterms,
                   u, v, w,
                   &chisq, FitHarmonic);
            break;
        case kFitFNHarmonicLog: 
            svdfit(xq,yq,sig,n,ai,nterms,
                   u, v, w,
                   &chisq, FitHarmonicPlusLog);
            break;
    }; 
    
    
    zls_DisposeQuantity2DArr(u);
    zls_DisposeQuantity2DArr(v);
    zls_DisposeQuantity1DArr(w);
    zls_DisposeQuantity1DArr(sig);
    
    return(0);
    
}


void mrqcof(Q1DArr x, Q1DArr y, Q1DArr sig2i, Integer ndata, 
            Q1DArr a, I1DArr ia, Integer ma, 
            Q2DArr alpha, Q1DArr beta, Q1DArr dyda, Real * chisq,
            void (*funcs)(Real, Real *, Real *, Real *, Integer));

void mrqcof(Q1DArr x, Q1DArr y, Q1DArr sig2i, Integer ndata, 
            Q1DArr a, I1DArr ia, Integer ma, 
            Q2DArr alpha, Q1DArr beta, Q1DArr dyda, Real * chisq,
            void (*funcs)(Real, Real *, Real *, Real *, Integer))
{
	Integer i,j,k,l,m;
    Integer mfit=0;
    
	Real ymod,wt,dy;//,sig2i;
    
    //Q1DArr dyda;
    
	//dyda=vector(1,ma);
   // zls_NewQuantity1DArr( &dyda, ma ); // 0 .. ma-1
    
	for (j=0;j<ma;j++)
		if (ia[j]== kFitFreeCoeff) mfit++;
    
	for (j=0;j<mfit;j++) {
		for (k=0; k<=j; k++) alpha[j][k] = 0.0;
		beta[j] = 0.0;
	}
    
	*chisq=0.0;
	for (i=0;i<ndata;i++) {
        
		(*funcs)(x[i],a,&ymod,dyda,ma);
        
		//sig2i=1.0/(sig[i]*sig[i]);
        
		dy=y[i]-ymod;
        
        j = 0;
		for (l=0;l<ma;l++) {
			if (ia[l]==kFitFreeCoeff) {
                
				wt=dyda[l]*sig2i[i];
                
                k = 0;
				for (m=0;m<=l;m++)
					if (ia[m]==kFitFreeCoeff){ 
                        alpha[j][k++] += wt*dyda[m];
                        //k++;
                    }
				beta[j++] += dy*wt;
                //j++;
			}
		}
        
		*chisq += dy*dy*sig2i[i];
	}
    
	for (j=0;j<mfit;j++)
		for (k=0;k<j;k++) alpha[k][j]=alpha[j][k];
    
    //zls_DisposeQuantity1DArr(dyda);
        
}


int mrqmin(Q1DArr x, Q1DArr y, Q1DArr sig2i, Integer ndata,
            Q1DArr a, I1DArr ia, Integer ma, 
            Q2DArr covar, Q2DArr alpha, Real *chisq,
            void (*funcs)(Real, Real *, Real *, Real *, Integer), 
            Real *alamda);

int mrqmin(Q1DArr x, Q1DArr y, Q1DArr sig2i, Integer ndata,
            Q1DArr a, I1DArr ia, Integer ma, 
            Q2DArr covar, Q2DArr alpha, Real *chisq,
            void (*funcs)(Real, Real *, Real *, Real *, Integer), 
            Real *alamda)
{
    /*	void covsrt(float **covar, int ma, int ia[], int mfit);
     void gaussj(float **a, int n, float **b, int m);
     void mrqcof(float x[], float y[], float sig[], int ndata, float a[],
     int ia[], int ma, float **alpha, float beta[], float *chisq,
     void (*funcs)(float, float [], float *, float [], int));
     */
    int err = 0;
    
	Integer j,k,l,m;
	static Integer mfit;
	static Real ochisq;
	static Q1DArr atry = NULL;
    static Q1DArr beta = NULL;
    static Q1DArr da   = NULL;
	static Q1DArr oneda = NULL;
	static Q1DArr dyda  = NULL;

	if (*alamda < 0.0) {
        
        zls_NewQuantity1DArr( &atry, ma ); // 0 .. ma-1
        zls_NewQuantity1DArr( &beta, ma ); // 0 .. ma-1
        zls_NewQuantity1DArr( &da  , ma ); // 0 .. ma-1
        zls_NewQuantity1DArr( &dyda, ma ); // 0 .. ma-1
        
        mfit=0;
		for (j=0;j<ma;j++)
			if (ia[j] == kFitFreeCoeff) mfit++;
        zls_NewQuantity1DArr(&oneda, mfit);
                
		*alamda=0.001;
        
		mrqcof(x,y,sig2i,ndata,
               a,ia,ma,
               alpha,beta,dyda,
               chisq,funcs);
        
		ochisq=(*chisq);
        
		for (j=0;j<ma;j++) atry[j]=a[j];
        
	}

    if ( atry   == NULL ) return memErr;
    if ( beta   == NULL ) return memErr;
    if ( da     == NULL ) return memErr;
    if ( dyda   == NULL ) return memErr;
    if ( oneda  == NULL ) return memErr;

    j = 0;
	for (l=0;l<ma;l++) {
		if (ia[l]==kFitFreeCoeff) {
            k = 0;
			for (m=0;m<ma;m++) {
				if (ia[m]==kFitFreeCoeff) {
					covar[j][k]=alpha[j][k];
                    k++;
				}
			}
			covar[j][j]=alpha[j][j]*(1.0+(*alamda));
			oneda[j]=beta[j];
            j++;
		}
	}
    
	err = gaussj(covar, mfit, oneda); 
    if ( err != 0) return err;

	for (j=0;j<mfit;j++) da[j]=oneda[j];
    
	if (*alamda == 0.0) {
		covsrt(covar,ma,ia,mfit);
		zls_DisposeQuantity1DArr(oneda);
        zls_DisposeQuantity1DArr(da);
        zls_DisposeQuantity1DArr(beta);
        zls_DisposeQuantity1DArr(atry);
        zls_DisposeQuantity1DArr(dyda);
		return err;
	}
    
    j=0;
	for (l=0;l<ma;l++)
		if (ia[l]==kFitFreeCoeff) atry[l]=a[l]+da[j++];
    
	mrqcof(x,y,sig2i,ndata,
           atry,ia,ma,
           covar,da, dyda,
           chisq,funcs);

	if (*chisq < ochisq) {
		*alamda *= 0.1;
		ochisq=(*chisq);
        j = 0;
		for (l=0;l<ma;l++) {
			if (ia[l]==kFitFreeCoeff) {
                k = 0;
				for (m=0;m<ma;m++) {
					if (ia[m]==kFitFreeCoeff) {
						alpha[j][k]=covar[j][k];
                        k++;
					}
				}
				beta[j] = da[j];
				a[l] = atry[l];
                j++;
			}
		}
        
	} else {
		*alamda *= 10.0;
		*chisq=ochisq;
	}
    
    return err;
    
}


// non-linear Levenberg-Marquardt gaussian fit with selectable terms
int MRQGaussFit ( Q1DArr   xq, Q1DArr  yq, Integer n,
            Q1DArr yerr, Integer errormode,
            I1DArr  fai, Q1DArr  ai, Q1DArr sai, Integer nterms,
            Integer fit, Real * rchi)
{
    // *** important that ai be set with intial estimates for coeffs

    int err = 0;

	int i;
	Real  chisq = 0.0;
    Integer itst, k;
    Real ochisq;
    Real alamda = -1.0;

    Integer na = 3;
    if (nterms <= 3) {
        na = 3;
    } else if (nterms <= 6) {
        na = 6;
    } else if (nterms <= 9) {
        na = 9;
    }

    Q2DArr covar;
    zls_NewQuantity2DArr(&covar, na, na);

    Q2DArr alpha;
    zls_NewQuantity2DArr(&alpha, na, na);

    Q1DArr sig2i;
    zls_NewQuantity1DArr(&sig2i, n);
    if ( yerr == NULL){
        if (errormode == kFitSqrtWeighting){
            for (i=0;i<n;i++) {
                if (yq[i] != 0.0){
                    sig2i[i] = 1.0/fabs(yq[i]); // 1/sqrt(y)^2
                } else {
                    sig2i[i] = 1.0;
                }
            }
        } else { // kFitNoErrorWeighting, or err not known
            for (i=0;i<n;i++) {
                sig2i[i] = 1.0;
            }
        }
    } else { // kFitYErrWeighting
        for (i=0;i<n;i++) {
            sig2i[i] = 1.0/(yerr[i]*yerr[i]);
        }
    }

    err = mrqmin(xq,yq,sig2i,n,
                 ai,fai,na,
                 covar,alpha,
                 &chisq,FitNGauss,&alamda);

    if( err != 0) return err;

    k=1;
    itst=0;
    for (;;) {
        /*
         printf("\n%s %2d %17s %10.4f %10s %9.2e\n","Iteration #",k,
         "chi-squared:",chisq,"alamda:",alamda);
         for (i=0;i<nterms;i++) printf(" a[%1i]    ",i);
         printf("\n");
         for (i=0;i<nterms;i++) printf("%9.4f",ai[i]);
         printf("\n");
         */
        k++;
        ochisq=chisq;

        err = mrqmin(xq,yq,sig2i,n,
                     ai,fai,na,
                     covar,alpha,
                     &chisq,FitNGauss,&alamda);

        if( err != 0) return err;

        if (chisq > ochisq)
            itst=0;
        else if (fabs(ochisq-chisq) < 0.1)
            itst++;
        if (itst < 4) continue;
        alamda=0.0;

        err = mrqmin(xq,yq,sig2i,n,
                     ai,fai,nterms,
                     covar,alpha,
                     &chisq,FitNGauss,&alamda);

        if( err != 0) return err;

        if ( sai) {
            for (i=0;i<nterms;i++) sai[i] = sqrt(covar[i][i]);
            /*
             printf("\nUncertainties:\n");
             for (i=0;i<nterms;i++) printf("%9.4f",sai[i]);
             printf("\n");
             */
        }
        break;
    }


    if (sai) for (i=0;i<na;i++) sai[i] = covar[i][i];

    if (rchi) *rchi = chisq;

    zls_DisposeQuantity1DArr(sig2i);
    zls_DisposeQuantity2DArr(alpha);
    zls_DisposeQuantity2DArr(covar);
    
    return(err);
    
}

// non-linear Levenberg-Marquardt gaussian fit with selectable terms
int MRQGaussPolyFit ( Q1DArr   xq, Q1DArr  yq, Integer n,
                      Q1DArr yerr, Integer errormode,
                      I1DArr  fai, Q1DArr  ai, Q1DArr sai, Integer nterms,
                      Integer fit, Real * rchi)
{
    // *** important that ai be set with intial estimates for coeffs

    int err = 0;

	int i;
	Real  chisq = 0.0;
    Integer itst, k;
    Real ochisq;
    Real alamda = -1.0;

    Integer na = 3;
    if (nterms <= 3) {
        na = 3;
    } else if (nterms > 6) {
        na = 6;
    } else {
        na = nterms;
    }

    Q2DArr covar;
    zls_NewQuantity2DArr(&covar, na, na);

    Q2DArr alpha;
    zls_NewQuantity2DArr(&alpha, na, na);

    Q1DArr sig2i;
    zls_NewQuantity1DArr(&sig2i, n);
    if ( yerr == NULL){
        if (errormode == kFitSqrtWeighting){
            for (i=0;i<n;i++) {
                if (yq[i] != 0.0){
                    sig2i[i] = 1.0/fabs(yq[i]); // 1/sqrt(y)^2
                } else {
                    sig2i[i] = 1.0;
                }
            }
        } else { // kFitNoErrorWeighting, or err not known
            for (i=0;i<n;i++) {
                sig2i[i] = 1.0;
            }
        }
    } else { // kFitYErrWeighting
        for (i=0;i<n;i++) {
            sig2i[i] = 1.0/(yerr[i]*yerr[i]);
        }
    }

    err = mrqmin(xq,yq,sig2i,n,
                 ai,fai,na,
                 covar,alpha,
                 &chisq,FitGaussPoly,&alamda);

    if( err != 0) return err;

    k=1;
    itst=0;
    for (;;) {
        /*
         printf("\n%s %2d %17s %10.4f %10s %9.2e\n","Iteration #",k,
         "chi-squared:",chisq,"alamda:",alamda);
         for (i=0;i<nterms;i++) printf(" a[%1i]    ",i);
         printf("\n");
         for (i=0;i<nterms;i++) printf("%9.4f",ai[i]);
         printf("\n");
         */
        k++;
        ochisq=chisq;

        err = mrqmin(xq,yq,sig2i,n,
                     ai,fai,na,
                     covar,alpha,
                     &chisq,FitGaussPoly,&alamda);

        if( err != 0) return err;

        if (chisq > ochisq)
            itst=0;
        else if (fabs(ochisq-chisq) < 0.1)
            itst++;
        if (itst < 4) continue;
        alamda=0.0;

        err = mrqmin(xq,yq,sig2i,n,
                     ai,fai,nterms,
                     covar,alpha,
                     &chisq,FitGaussPoly,&alamda);

        if( err != 0) return err;

        if ( sai) {
            for (i=0;i<nterms;i++) sai[i] = sqrt(covar[i][i]);
            /*
             printf("\nUncertainties:\n");
             for (i=0;i<nterms;i++) printf("%9.4f",sai[i]);
             printf("\n");
             */
        }
        break;
    }


    if (sai) for (i=0;i<na;i++) sai[i] = covar[i][i];

    if (rchi) *rchi = chisq;

    zls_DisposeQuantity1DArr(sig2i);
    zls_DisposeQuantity2DArr(alpha);
    zls_DisposeQuantity2DArr(covar);
    
    return(err);
    
}

