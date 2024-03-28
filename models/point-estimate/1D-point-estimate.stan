functions {
  real partial_sum(array[] int score_slice,
                   int start, int end,
                   vector yj,
                   vector yb,
                   vector theta)
{
    real partial_target = 0;
    vector[2] lp;
    int slice_length = end-start+1;

    for (k in 1:slice_length)
     {
     lp[1] = log(yj)[score_slice[k]];
     lp[2] = log(yb)[score_slice[k]];

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
  int<lower=1, upper=m> w_j_mode;
  int<lower=1, upper=m> w_b_mode;
  real<lower=0> permutation_factor;

}



parameters {
  vector<lower=0>[m-2] a_j;	
  vector<lower=0>[m-2] a_b;	
  simplex[2] theta; // mixture coefficient for the 3 classes: bbbb, bbjj (in any order) & jjjj
}



transformed parameters{
  ordered[2] y5;   // this parameter will reinforce correct labelling, avoiding label switch. Because the 5th bin class0 i s greater than class1 always

  vector[m-1] p_j;
  vector[m-1] logp_j;
  vector[m-2] sign_j;
  sign_j = rep_vector(-1.0,m-2);                                // creates vector smaller in one element, with all components equal to -1
  sign_j[1:(w_j_mode-1)] = rep_vector(1.0,w_j_mode-1);                  // put +1 up to k-1, and leave others in -1
  logp_j = append_row(0.0,   cumulative_sum (sign_j .* a_j));   // each component is the sum of all the previous one in cumulative_sum
                                                                // (kind of an integral).  x .*= y means x = x * y element-wise.
  p_j =  softmax(logp_j);                 // Here there is some magic. You are doing a w_mode-weighted-average of



  vector[m-1] p_b;
  vector[m-1] logp_b;
  vector[m-2] sign_b;
  sign_b = rep_vector(-1.0,m-2);                                // creates vector smaller in one element, with all components equal to -1
  sign_b[1:(w_b_mode-1)] = rep_vector(1.0,w_b_mode-1);                  // put +1 up to k-1, and leave others in -1
  logp_b = append_row(0.0,   cumulative_sum (sign_b .* a_b));   // each component is the sum of all the previous one in cumulative_sum
                                                                // (kind of an integral).  x .*= y means x = x * y element-wise.
  p_b =  softmax(logp_b);                 // Here there is some magic. You are doing a w_mode-weighted-average of


  y5[1] = p_b[5];			// let's try this to avoid label switch,  I 've changed to bin 8, because it was failing with bin 5... too close to the start...
  y5[2] = p_j[5];
				
}

model {
  int grainsize = 1;
  theta ~ dirichlet([1,1]);
  a_j ~ normal(0,0.5);
  a_b ~ normal(0,0.5);

  target += reduce_sum(partial_sum, score, grainsize, p_j, p_b, theta);


}
