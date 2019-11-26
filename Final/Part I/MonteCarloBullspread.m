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
    
%     set_parameters;
%     Smax = 200;
%     sigma=0.25;
    S0 = Smin:Smax;
    confidence_sample = @(v) (sqrt(v)*1.96/0.05)^2;

    prices = zeros(4,Smax);
    variances = zeros(4,Smax);
    errors = zeros(4,Smax);
    times = zeros(4,Smax);
    sample_sizes = zeros(1,4);

    % Naive method
    for i = 1:Smax
        start = cputime;
        dW = sqrt(T)*randn(M,Smax);
        ST = zeros(M,Smax);
        for j = 1:M
            ST(j,i) = S0(i)*exp((r-0.5*sigma^2)*T+sigma*dW(j,i));
        end
        prices(1,i) = mean(payoff(ST(:,i)));
        variances(1,i) = mean(var(ST));
        errors(1,i) = BS_bullspread(i) - prices(1,i);   
        times(1,i) = cputime-start;
    end
    sample_sizes(1) = confidence_sample(mean(variances(1,:)));

    % Antithetic variance reduction
    for i = 1:Smax
        start = cputime;
        dW = sqrt(T)*randn(M,Smax);
        Splus = zeros(M,Smax);
        Sminus = zeros(M,Smax);
        for j = 1:M
            Splus(j,i) = S0(i)*exp((r-0.5*sigma^2)*T+sigma*dW(j,i)); 
            Sminus(j,i) = S0(i)*exp((r-0.5*sigma^2)*T-sigma*dW(j,i)); 
        end
        Z = (payoff(Splus(:,i))+payoff(Sminus(:,i)))/2;
        prices(2,i) = mean(Z);
        variances(2,i) = var(Z);
        errors(2,i) = BS_bullspread(i) - prices(2,i);   % bullspread -> BS_payoff
        times(2,i) = cputime-start;
    end
    sample_sizes(2) = confidence_sample(mean(variances(:,2)));


    % Control variates
    g = @(S) S;
    f = @(S) payoff(S);
    for i = 1:Smax
        start = cputime;
        gm = S0(i)*exp(r*T);
%         gv = S0(i)^2*exp(2*r*T)*(exp(sigma^2*T)-1);
        dW = sqrt(T)*randn(M,Smax);
        
        fc = zeros(M,Smax);
        for j = 1:M
            ST = S0(i)*exp((r-0.5*sigma^2)*T+sigma.*dW(j,:));
            covariance_matrix = cov(f(ST),ST);
            c = covariance_matrix(1,2)/var(ST);
%             fcv = var(f(ST))*(1-(covariance_matrix(1,2))^2/(var(f(ST))*var(g(ST))));
            fc(j,:) = f(ST)-c*(g(ST)-gm);
        end
        prices(3,i) = mean(fc(:,i));
        variances(3,i) = mean(var(fc));
        times(3,i) = cputime-start;
        errors(3,i) = BS_bullspread(i) - prices(3,i);
        times(3,i) = cputime-start;
    end
    sample_sizes(3) = confidence_sample(mean(variances(3,:)));
    
    % Importance sampling
    for i = 1:Smax
        start = cputime;
        y0 = normcdf((log(K1/S0(i))-(r-0.5*sigma^2)*T)/(sigma*sqrt(T)));
        Y = y0 + (1-y0)*rand(1,Smax);
        X = norminv(Y);
        ST = S0(i)*exp((r-0.5*sigma^2)*T+sigma*sqrt(T)*X);
        ST(ST==Inf) = 0; % SET ALL ST = INF TO ZERO 
        f = exp(-r*T).*(ST-K1-max(ST-K2,0));
        prices(4,i) = (1-y0)*mean(f);
        variances(4,i) = (1-y0)^2*var(f);
        errors(4,i) = BS_bullspread(i) - prices(4,i);
        times(4,i) = cputime-start;
    end
    sample_sizes(1) = confidence_sample(mean(variances(1,:)));
    
end