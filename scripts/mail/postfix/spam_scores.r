hits <-read.table('hits.txt', header=TRUE)
hist(hits$hits, main='Spam scores', xlab='Score', ylab='Frequency', breaks=60, xlim=c(-10, 70), col='gray')
