set_parameters;
sample_size = @(v) (sqrt(v)*1.96/0.05)^2;

M = 1000;
price = zeros(3,M);
variance = zeros(3,M);
errors = zeros(3,M);
time = zeros(3,M);

S = zeros(Smax, M);

% TODO:
% - Simulate M times for S0 = 1:100???


% Naive method
dW = sqrt(dt)*randn(1,M);
for S0 = Smin:Smax
    for i = 1:M
        start = cputime;
        [S(S0,:), price] = simulate_geometric_bm(S0, r, sigma, N, T);
        variance(i,1) = var(payoff(ST));
        time(i,1) = cputime-start;
    end
end
sample_size_mc(1) = sample_size(mean(variance(:,1)));

% Antithetic variance reduction
for i = 1:M
    time(i,2) = cputime;
    dST = rate(0).*S0.*T + volatility(S0,0).*S0.*dW(i);
    Splus = S0 + dST;
    Sminus = S0 - dST;
    Z = (payoff(Splus)+payoff(Sminus))/2;
    price(i,2) = mean(Z);
    variance(i,2) = var(Z);
%    errors(i,2) = price_BS - price(i,2);
    time(i,2) = cputime-start;
end
sample_size_mc(2) = sample_size(mean(variance(:,2)));

% Control variates
g = @(S) S;
for i = 1:M
   	start = cputime;
    % TODO: FIX GM
    gm = S0.*exp(T*(rate(T)));
    gv = S0.^2.*exp(2*rate(0)*T).*(exp(volatility(S0,0).^2.*T)-1);
    dST = rate(0).*S0.*T + volatility(S0,0).*S0.*dW(i);
    ST = S0 + dST;
    covariance_matrix = cov(payoff(ST),ST);
    c = covariance_matrix(1,2)/var(ST);
    fcv = var(payoff(ST))*(1-(covariance_matrix(1,2))^2/(var(payoff(ST))*var(g(ST))));
    fc = payoff(ST)-c.*(g(ST)-gm);
    price(i,3) = mean(fc);
    variance(i,3) = var(fc);
    time(i,3) = cputime-start;
end

sample_size_mc(3) = sample_size(mean(variance(:,3)));

compare_monte_carlo(mean(price), mean(variance), mean(time), sample_size_mc)

