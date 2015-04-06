#include <iostream>
#include <math.h>
#include <vector>
#include <sstream>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_odeiv2.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_eigen.h>
#include <stdio.h>
#include <boost/random.hpp>
#include <boost/random/normal_distribution.hpp>

using namespace std;

gsl_matrix* MatrixSquareRoot(int dim, gsl_matrix * matrix_in){

	gsl_permutation * perm = gsl_permutation_alloc(dim);
	int s;
	gsl_vector_complex *eval = gsl_vector_complex_alloc(dim);
	gsl_matrix_complex *evec = gsl_matrix_complex_alloc(dim, dim);

	gsl_eigen_nonsymmv_workspace *w = gsl_eigen_nonsymmv_alloc(dim);

	gsl_eigen_nonsymmv(matrix_in, eval, evec, w);
	gsl_eigen_nonsymmv_free(w);
	gsl_eigen_nonsymmv_sort(eval, evec, GSL_EIGEN_SORT_ABS_DESC);

	gsl_vector_view eval_view = gsl_vector_complex_real(eval);
	gsl_vector *eval_real = &eval_view.vector;

	for(int i=0;i<dim;i++){
		cout<<gsl_vector_get(eval_real,i)<<endl;
	}

	gsl_matrix *evec_real = gsl_matrix_alloc(dim,dim);

	for (int i = 0; i < dim; i++){
		for (int j = 0; j < dim; j++){
			gsl_matrix_set(evec_real,i,j,GSL_REAL(gsl_matrix_complex_get(evec, i, j)));
		}
	}

	for(int m=0;m<3;m++){
		cout << gsl_matrix_get(evec_real,m,0) << ","<< gsl_matrix_get(evec_real,m,1) << ","<< gsl_matrix_get(evec_real,m,2) << endl;
	}

	gsl_matrix *sqrt_e = gsl_matrix_alloc(dim,dim);
	gsl_matrix_set_zero(sqrt_e);
	for(int i=0;i<dim;i++){
		gsl_matrix_set(sqrt_e,i,i,sqrt(gsl_vector_get(eval_real,i)));
	}

	for(int m=0;m<3;m++){
		cout << gsl_matrix_get(sqrt_e,m,0) << ","<< gsl_matrix_get(sqrt_e,m,1) << ","<< gsl_matrix_get(sqrt_e,m,2) << endl;
	}


	gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,evec_real,sqrt_e,0.0,matrix_in);

	for(int m=0;m<3;m++){
		cout << gsl_matrix_get(matrix_in,m,0) << ","<< gsl_matrix_get(matrix_in,m,1) << ","<< gsl_matrix_get(matrix_in,m,2) << endl;
	}

	gsl_matrix * evec_inv = gsl_matrix_alloc(dim,dim);
	gsl_matrix * matrix_out = gsl_matrix_alloc(dim,dim);
	gsl_linalg_LU_decomp (evec_real, perm, &s);
	gsl_linalg_LU_invert (evec_real, perm, evec_inv);
	gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,matrix_in,evec_inv,0.0,matrix_out);

	return matrix_out;
}

unsigned char LinearEncode( double val, double min, double max, int bits ) {
	unsigned char transmit_val;
	if ( val <= min ) return 0;
	else if ( val >= max ) return pow(2,bits)-1;
	else {
		double ratio = (val-min)/(max-min);
		double scaled = ratio * (pow(2,bits)-1);
		return floor( scaled + .5 );
	}
}

double LinearDecode( unsigned char val, double min, double max, int bits ) {
	double ratio = val / ( pow(2.0,bits) - 1.0 );
	return min + ratio * ( max - min );
}

unsigned char FlexibleEncode(double val,
		std::vector<double> & range_divs, int bits) {

	if (range_divs.size() != pow(2, bits) - 1) {
		std::stringstream ss;
		ss << "Specified number of bits (" << bits;
		ss << ") does not match vector size (" << range_divs.size();
		ss << ")";
		cout << ss.str() << endl;
		//        handleDebug(ss.str());
		return 0x00;
	}

	unsigned char transmit_val;

	for (int i = 0; i < range_divs.size() - 1; i++) {
		if ( val < range_divs[i] )
			return i;
	}
	return range_divs.size();
}

double random_generator(boost::variate_generator<boost::mt19937, boost::normal_distribution<> > &local_gen){
	return local_gen();
}

int func(double t, const double y[], double f[], void *params){

	struct ode_params{
		double n;
		double v;
	};

	ode_params PARAM;
	PARAM = *(ode_params *)params;

	f[0] = PARAM.n;
	f[1] = PARAM.v*cos(y[0]);
	f[2] = PARAM.v*sin(y[0]);
	return GSL_SUCCESS;
}

int jac(double t, const double y[], double *dfdy, double dfdt[], void *params){

	struct ode_params{
		double n;
		double v;
	};

	ode_params PARAM;
	PARAM = *(ode_params *)params;

	gsl_matrix_view dfdy_mat = gsl_matrix_view_array (dfdy, 3, 3);
	gsl_matrix * m = &dfdy_mat.matrix;
	gsl_matrix_set_zero(m);
	dfdt[0] = 0.0;
	dfdt[1] = 0.0;
	return GSL_SUCCESS;
}

int main () {

	int s_dim = 3;
	string txtfile = "HermiteMatrices.txt";
	std::vector<gsl_matrix*> s1 = vector<gsl_matrix*>(s_dim);
	std::vector<gsl_matrix*>  s2 = vector<gsl_matrix*>(s_dim);
	std::vector<gsl_matrix*>  s3 = vector<gsl_matrix*>(s_dim);

	FILE* f = fopen(txtfile.c_str(),"r");

	for(int i=0;i<s_dim;i++){
		s1[i] = gsl_matrix_alloc(s_dim, s_dim);
		gsl_matrix_fscanf(f,s1[i]);
	}

	for(int i=0;i<s_dim;i++){
		s2[i] = gsl_matrix_alloc(s_dim, s_dim);
		gsl_matrix_fscanf(f,s2[i]);
	}

	for(int i=0;i<s_dim;i++){
		s3[i] = gsl_matrix_alloc(s_dim, s_dim);
		gsl_matrix_fscanf(f,s3[i]);
	}
	fclose(f);

	for(int i=0;i<s_dim;i++){	//iterating over sigma points
			for(int j=0;j<s_dim;j++){
				for(int k=0;k<s_dim;k++){
					cout << gsl_matrix_get(s1[i],j,k)<<","<<gsl_matrix_get(s2[i],j,k)<<","<< gsl_matrix_get(s3[i],j,k)<<endl;
				}
			}
	}

	//	struct ode_params{
	//		double n;
	//		double v;
	//	};
	//
	//	boost::variate_generator<boost::mt19937, boost::normal_distribution<> >
	//	generator(boost::mt19937(time(0)),
	//			boost::normal_distribution<>());
	//
	//	double r = generator();
	//	ode_params PARAM;
	//	PARAM.n = r;
	//	PARAM.v = 1;
	//
	//	gsl_odeiv2_system sys = {func, jac, 3, &PARAM};
	//
	//	gsl_odeiv2_driver * d = gsl_odeiv2_driver_alloc_y_new (&sys, gsl_odeiv2_step_rkf45,1e-6, 1e-6, 1e-6);
	//	double t = 0.0;
	//	double y[] = {0, 100, -30};
	//	int status = gsl_odeiv2_driver_apply (d, &t, 5, y);
	//
	//	cout << r<< endl;
	//	cout << y[0] << "," << y[1] << "," << y[2] << endl;

	//    double data[] = { 1  , 0, 0,
	//    				0, 0.88387, -0.161121,
	//    				0 ,-0.161121, 0.776456};
	//
	//    gsl_matrix_view m = gsl_matrix_view_array(data, 3, 3);
	//
	//    for (int i = 0; i < 3; i++){
	//          cout << gsl_matrix_get (&m.matrix, i, 0)<<","<< gsl_matrix_get (&m.matrix, i, 1)<<","<< gsl_matrix_get (&m.matrix, i, 2)<<endl;;
	//    }
	//    cout <<endl;
	//    gsl_matrix* matrix_out = MatrixSquareRoot(3,&m.matrix);
	//
	//    for (int i = 0; i < 3; i++){
	//          cout << gsl_matrix_get (matrix_out, i, 0)<<","<< gsl_matrix_get (matrix_out, i, 1)<<","<< gsl_matrix_get (matrix_out, i, 2)<<endl;;
	//    }
	//    unsigned char a = 22;
	//    unsigned char b = 4;
	//    cout << hex << (int) ( (a<<3) + b ) << endl;

	//    std::vector<double> range_divs;
	//    for ( int i=2; i<9; i++ ) {
	//        range_divs.push_back(i*10);
	//    }
	//
	//    unsigned char range =FlexibleEncode(81,range_divs,3);
	//    range+=0xf8;
	//
	//    cout << (int) (range & 0x07)<< endl;

	//	double val = 310;
	//	unsigned char sent = LinearEncode( val, 0, 310, 5 );
	//	cout << (int) sent << endl;
	//	double received = LinearDecode( sent, 0, 310, 5);
	//	cout << received << endl;
	//	cout << (int) LinearEncode( val, 0, 310, 5) << endl;
	//	cout << hex << (int) LinearEncode( val, 0, 310, 5) << endl;
	//	cout << hex << (int) (LinearEncode( val, 0, 310, 5)<<3) << endl;
}
