\name{plot.cv.customizedGlmnet}
\alias{plot.cv.customizedGlmnet}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
visualize variables selected in each customized training subset, from a
cross-validated model
}
\description{
Produces a plot, with a row for each customized training submodel, showing
the variables selected in the subset, with variables along the horizonal axis.
The lambda used is the one which minimizes CV error.
}
\usage{
\method{plot}{cv.customizedGlmnet}(x, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
a fitted \code{cv.customizedGlmnet} object
}
    \item{\dots}{
        ignored
    }
}
%\details{
%%  ~~ If necessary, more details than the description above ~~
%}
%\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
%}
%\references{
%% ~put references to the literature/web site here ~
%}
\author{
Scott Powers, Trevor Hastie, Robert Tibshirani
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{plot}}, \code{\link{cv.customizedGlmnet}}
}
\examples{
require(glmnet)


#   Simulate three groups, each with a different sparse linear model
#   producing the response, and fit customized training model (with CV) to the
#   synthetic data

# Simulation parameters:
n = m = 300
p = 100
q = 10
K = 3
sigmaC = 10
sigmaX = sigmaY = 1
set.seed(5914)

# Produce the synthetic data:
beta = matrix(0, nrow = p, ncol = K)
for (k in 1:K) beta[sample(1:p, q), k] = 1
c = matrix(rnorm(K*p, 0, sigmaC), K, p)
eta = rnorm(K)
pi = (exp(eta)+1)/sum(exp(eta)+1)
z = t(rmultinom(m + n, 1, pi))
x = crossprod(t(z), c) + matrix(rnorm((m + n)*p, 0, sigmaX), m + n, p)
y = rowSums(z*(crossprod(t(x), beta))) + rnorm(m + n, 0, sigmaY)

x.train = x[1:n, ]
y.train = y[1:n]
x.test = x[n + 1:m, ]
foldid = sample(rep(1:10, length = nrow(x.train)))

# Fit the customized training model with CV:
fit2 = cv.customizedGlmnet(x.train, y.train, x.test, Gs = 1:3,
    family = "gaussian", foldid = foldid)

# Plot nonzero coefficients by group:
plot(fit2)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
