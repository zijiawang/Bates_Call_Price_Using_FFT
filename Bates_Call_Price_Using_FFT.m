% Fast Fourier Transform for the Bates Model
 
clc; clear;

% Required inputs
N = 2^12;          % Number points for the FFT
S0 = 39;           % Spot price.
r = 0.05;          % Risk free rate.
q = 0.0;          % Dividend yield
tau = 0.292;          % Time to maturity.
kappa  = 0.45;      % Heston parameter: mean reversion speed.
theta  = 0.4;     % Heston parameter: mean reversion level.
sigma  = 0.32;      % Heston parameter: volatility of vol
rho    = -0.58347;     % Heston parameter: correlation
v0     = 0.1;     % Heston parameter: initial variance.
lambdaJ = 0.032;       % Jump frequency parameter
muJ     = 0.004987;    % Jump mean
sigmaJ  = 0.14725;    % Jump volatility
param = [kappa theta sigma v0 rho lambdaJ muJ sigmaJ];

param = [kappa theta sigma v0 rho lambdaJ muJ sigmaJ];

trap = 1;          % Heston trap (1) or original Heston (0) formulation
alpha = 1.5;       % Dampening factor
uplimit = 100;     % Upper limit of integration
fast = 1;          % Choice of fast (1) or slow (0) algorithm

%% Run the Fast Fourier Transform using the trapezoidal rule
[CallT K lambdainc eta] =  BatesCallFFT(N,uplimit,S0,r,q,tau,param,alpha,fast,'T');

% Run the Fast Fourier Transform using Simpson's rule
[CallS K lambdainc eta] =  BatesCallFFT(N,uplimit,S0,r,q,tau,param,alpha,fast,'S');

% Obtain the results near the ATM strikes
ATM = [find(round(K)==S0)-10:find(round(K)==S0)+10];

% Truncate the outputted calls and strikes
CallT = CallT(ATM);
CallS = CallS(ATM);
K     = K(ATM);

%% Closed form price and errors
% Gauss Laguerre weights and abscissas
xw = [...
    0.0445    0.1142;
    0.2345    0.2661;
    0.5769    0.4188;
    1.0724    0.5725;
    1.7224    0.7276;
    2.5283    0.8845;
    3.4922    1.0436;
    4.6165    1.2053;
    5.9040    1.3702;
    7.3581    1.5388;
    8.9829    1.7116;
   10.7830    1.8895;
   12.7637    2.0730;
   14.9314    2.2633;
   17.2914    2.4622;
   19.8586    2.6600;
   22.6270    2.8909;
   25.6295    3.1235;
   28.8726    3.3645;
   32.3193    3.6697;
   36.1371    4.1866;
   40.1256    4.1695;
   44.4829    4.4523;
   49.3076    4.9941;
   54.2188    5.8800;
   59.9992    5.3379;
   65.9033    6.8224;
   72.7216    6.8573;
   80.1762    8.0512;
   88.7377    9.1847;
   98.8293   11.1658;
  111.7514   15.3900];
x = xw(:,1);
w = xw(:,2);

for k=1:length(K);
    CallE(k) = SVprice('Bates','C',param,tau,K(k),S0,r,q,x,w);
end
ErrorT = (CallT-CallE')./CallE'.*100;
ErrorS = (CallS-CallE')./CallE'.*100;

MSET = mean(abs(ErrorT));
MSES = mean(abs(ErrorS));

%% Print the results
disp('Strike       Exact       FFT Trapz   FFT Simp   %Error Tr   %Error Sim')
disp('----------------------------------------------------------------------')
disp(num2str([K CallE' CallT CallS ErrorT ErrorS],'%12.4f'))
disp('----------------------------------------------------------------------')
disp(' ')

% Print the increments for integration and for log strikes
disp(['Integration increment ' num2str(eta,'%10.6f')])
disp(['Log strike increment  ' num2str(lambdainc,'%10.6f\n')])

% Print the errors
disp(['Trapezoidal FFT mean absolute error ' num2str(MSET)])
disp(['Simpsons FFT mean absolute error    ' num2str(MSES)])

