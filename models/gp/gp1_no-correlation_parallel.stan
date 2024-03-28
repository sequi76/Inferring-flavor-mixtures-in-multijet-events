functions {
  real partial_sum(array[,] int score_slice,
                   int start, int end,
                   vector yj,
		   vector yb,
                   vector theta) 
{
    real permutation_factor = 1.0/6;
    real partial_target = 0;
    vector[3] lp;
    vector[6] lp2;

    for (k in 1:(end-start+1))
     {
     lp2[1] = log(permutation_factor) + log_softmax(yj)[score_slice[k,1]] + log_softmax(yj)[score_slice[k,2]] + log_softmax(yb)[score_slice[k,3]] + log_softmax(yb)[score_slice[k,4]];
     lp2[2] = log(permutation_factor) + log_softmax(yj)[score_slice[k,1]] + log_softmax(yb)[score_slice[k,2]] + log_softmax(yj)[score_slice[k,3]] + log_softmax(yb)[score_slice[k,4]];
     lp2[3] = log(permutation_factor) + log_softmax(yj)[score_slice[k,1]] + log_softmax(yb)[score_slice[k,2]] + log_softmax(yb)[score_slice[k,3]] + log_softmax(yj)[score_slice[k,4]];
     lp2[4] = log(permutation_factor) + log_softmax(yb)[score_slice[k,1]] + log_softmax(yj)[score_slice[k,2]] + log_softmax(yj)[score_slice[k,3]] + log_softmax(yb)[score_slice[k,4]];
     lp2[5] = log(permutation_factor) + log_softmax(yb)[score_slice[k,1]] + log_softmax(yj)[score_slice[k,2]] + log_softmax(yb)[score_slice[k,3]] + log_softmax(yj)[score_slice[k,4]];
     lp2[6] = log(permutation_factor) + log_softmax(yb)[score_slice[k,1]] + log_softmax(yb)[score_slice[k,2]] + log_softmax(yj)[score_slice[k,3]] + log_softmax(yj)[score_slice[k,4]];

     lp[1] = log_softmax(yj)[score_slice[k,1]] + log_softmax(yj)[score_slice[k,2]] + log_softmax(yj)[score_slice[k,3]] + log_softmax(yj)[score_slice[k,4]];
     lp[2] = log_sum_exp(lp2);  
     lp[3] = log_softmax(yb)[score_slice[k,1]] + log_softmax(yb)[score_slice[k,2]] + log_softmax(yb)[score_slice[k,3]] + log_softmax(yb)[score_slice[k,4]];

     partial_target += log_mix(theta, lp);
     }

    return partial_target;
  }


}



data {
  int<lower=1> m;  // steps in the discretization
  int<lower=1> N;  // data points
  array[N,4] int<lower=1, upper=m> score;  // b-tagging score for jet#1 
  vector[m-1] muj;                  // central value of prior b-tagging distribution for j-jets
  vector[m-1] mub;                  // central value of prior b-tagging distribution for b-jets
  real<lower=0> permutation_factor;
  //real<lower=0> mu_sigma;
  //real<lower=0> sigma_sigma;
  //real<lower=0> mu_correlation;
  //real<lower=0> sigma_correlation;      
  real<lower=0> sigma;              // Covariance matrix parameter, fixed now
  real<lower=0> correlation;        // Covariance matrix parameter, fixed now

}

parameters {
  ordered[2] y5;   // this parameter will reinforce correct labelling, avoiding label switch. Because the 5th bin class0 i s greater than class1 always
  vector[m-2] yj_remain;   // posterior samples of b-tagging distribution for j-jets
  vector[m-2] yb_remain;   // posterior samples of b-tagging distribution for b-jets
  simplex[3] theta; // misture coefficient for the 3 classes: bbbb, bbjj (in any order) & jjjj
}

transformed parameters {    
  vector[m-1]  yj;
  vector[m-1]  yb;
  
  yb[1:4]= yb_remain[1:4];
  yb[5] = y5[1];
  yb[6:m-1] = yb_remain[5:m-2];

  yj[1:4]= yj_remain[1:4];
  yj[5] = y5[2];
  yj[6:m-1] = yj_remain[5:m-2];
 }

model {
  int grainsize = 1;
  theta ~ dirichlet([1,1,1]);
  matrix[m-1, m-1] K;
  for (i in 1:m-1)
     for (j in 1:m-1)
       K[i, j] = sigma * exp( - pow((abs(i-j)/(correlation)),2));
  yj ~ multi_normal(muj, K);  
  yb ~ multi_normal(mub, K); 
  
  target += reduce_sum(partial_sum, score, grainsize, yj, yb, theta);
}
