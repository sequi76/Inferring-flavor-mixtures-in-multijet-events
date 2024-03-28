functions {
  real partial_sum(array[] int score_slice,
                   int start, int end,
                   vector yj,
		   vector yb,
                   vector theta) 
{
    real partial_target = 0;
    vector[2] lp;

    for (k in 1:(end-start+1))
     {
     lp[1] = log_softmax(yj)[score_slice[k]];
     lp[2] = log_softmax(yb)[score_slice[k]];

     partial_target += log_mix(theta, lp);
     }

    return partial_target;
  }


}



data {
  int<lower=1> m;  // steps in the discretization
  int<lower=1> N;  // data points
  array[N] int<lower=1, upper=m> score;  // b-tagging score for jet#1 
  vector[m-1] muj;                  // central value of prior b-tagging distribution for j-jets
  vector[m-1] mub;                  // central value of prior b-tagging distribution for b-jets
  //real<lower=0> permutation_factor;
  //real<lower=0> mu_sigma;
  //real<lower=0> sigma_sigma;
  //real<lower=0> mu_correlation;
  //real<lower=0> sigma_correlation;      
  real<lower=0> sigma;              // Covariance matrix parameter, fixed now
  real<lower=0> correlation;        // Covariance matrix parameter, fixed now

}

parameters {
  ordered[2] y8;   // this parameter will reinforce correct labelling, avoiding label switch. Because the 5th bin class0 i s greater than class1 always
  vector[m-2] yj_remain;   // posterior samples of b-tagging distribution for j-jets
  vector[m-2] yb_remain;   // posterior samples of b-tagging distribution for b-jets
  simplex[2] theta; // misture coefficient for the 3 classes: bbbb, bbjj (in any order) & jjjj
}

transformed parameters {    
  vector[m-1]  yj;
  vector[m-1]  yb;
  
  yb[1:4]= yb_remain[1:4];
  yb[5] = y8[1];
  yb[6:m-1] = yb_remain[5:m-2];

  yj[1:4]= yj_remain[1:4];
  yj[5] = y8[2];
  yj[6:m-1] = yj_remain[5:m-2];
 }

model {
  int grainsize = 1;
  theta ~ dirichlet([1,1]);
  matrix[m-1, m-1] K;
  for (i in 1:m-1)
     for (j in 1:m-1)
       K[i, j] = sigma * exp( - pow((abs(i-j)/(correlation)),2));
  yj ~ multi_normal(muj, K);  
  yb ~ multi_normal(mub, K); 
  
  target += reduce_sum(partial_sum, score, grainsize, yj, yb, theta);
}
