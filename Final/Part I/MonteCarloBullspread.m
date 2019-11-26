function [times, prices, variances, errors, sample_sizes] = MonteCarloBullspread(Smin, Smax, K1, K2, r, sigma, T, M, payoff, BS_bullspread)
    % INPUTS:
    %   - M:            Number of Monte Carlo simulations
    %
    % OUTPUTS:
    %   - times:        CPU times required to run each of the methods
    %   - prices:       Option prices as a function of stock price each of the methods 
    %   - variances:    Variances from each of the methods
    %   - errors:       
    %   - sample_sizes: 
    
    S0 = Smin:Smax;
    confidence_sample = @(v) (sqrt(v).*1.96/0.05).^2;

    prices = zeros(4,Smax);
    variances = zeros(4,Smax);
    errors = zeros(4,Smax);
    times = zeros(4,Smax);
    sample_sizes = zeros(4, Smax);

    % Naive method
    ST = zeros(Smax,M);
    dW = sqrt(T)*randn(Smax,M);
    
    for i = 1:Smax
        start = cputime;
        ST(i,:) = S0(i)*exp((r-0.5*sigma^2)*T+sigma.*dW(i,:));
        prices(1,i) = mean(payoff(ST(i,:)));
        variances(1,i) = var(payoff(ST(i,:)));
        errors(1,i) = BS_bullspread(i) - prices(1,i);   
        times(1,i) = cputime-start;
    end
    sample_sizes(1,:) = confidence_sample(variances(1,:));

    % Antithetic variance reduction
    Splus = zeros(Smax,M);
    Sminus = zeros(Smax,M);
    dW = sqrt(T)*randn(Smax,M);
    for i = 1:Smax
        start = cputime;
        Splus(i,:) = S0(i)*exp((r-0.5*sigma^2)*T+sigma.*dW(i,:)); 
        Sminus(i,:) = S0(i)*exp((r-0.5*sigma^2)*T-sigma.*dW(i,:)); 
        Z = (payoff(Splus(i,:))+payoff(Sminus(i,:)))/2;
        prices(2,i) = mean(Z);
        variances(2,i) = var(Z);
        errors(2,i) = BS_bullspread(i) - prices(2,i);   % bullspread -> BS_payoff
        times(2,i) = cputime-start;
    end
    sample_sizes(2,:) = confidence_sample(variances(2,:));


    % Control variates
    g = @(S) S;
    f = @(S) payoff(S);
    dW = sqrt(T)*randn(Smax);

    for i = 1:Smax
        start = cputime;
        gm = S0(i)*exp(r*T);
%         gv = S0(i)^2*exp(2*r*T)*(exp(sigma^2*T)-1);
        
        ST = S0(i)*exp((r-0.5*sigma^2)*T+sigma.*dW(i,:));
        covariance_matrix = cov(f(ST),ST);
        c = covariance_matrix(1,2)/var(ST);
%       fcv = var(f(ST))*(1-(covariance_matrix(1,2))^2/(var(f(ST))*var(g(ST))));
        fc = f(ST)-c*(g(ST)-gm);
        
        prices(3,i) = mean(fc);
        variances(3,i) = var(fc);
        times(3,i) = cputime-start;
        errors(3,i) = BS_bullspread(i) - prices(3,i);
        times(3,i) = cputime-start;
    end
    sample_sizes(3,:) = confidence_sample(variances(3,:));    

    % Importance sampling
    for i = 1:Smax
        start = cputime;
        y0 = normcdf((log(K1/S0(i))-(r-0.5*sigma^2)*T)/(sigma*sqrt(T)));
        Y = y0 + (1-y0)*rand(1,M);
        X = norminv(Y);
        ST = S0(i)*exp((r-0.5*sigma^2)*T+sigma*sqrt(T)*X);
        ST(ST==Inf) = 0; % SET ALL ST = INF TO ZERO 
        fST = (1-y0)*exp(-r*T).*(ST-K1-max(ST-K2,0));
        prices(4,i) = mean(fST);
        variances(4,i) = var(fST);
        errors(4,i) = BS_bullspread(i) - prices(4,i);
        times(4,i) = cputime-start;
    end
    sample_sizes(4,:) = confidence_sample(variances(4,:));
    
end