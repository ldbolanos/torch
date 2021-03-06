context("indexing")

test_that("[ works", {
  x <- torch_randn(c(10,10,10))
  expect_equal(as_array(x[1,1,1]), as_array(x)[1,1,1])
  expect_equal(as_array(x[1,,]), as_array(x)[1,,])  
  expect_equal(as_array(x[1:5,,]), as_array(x)[1:5,,])
  expect_equal(as_array(x[1:10:2,,]), as_array(x)[seq(1,10, by = 2),,])
  
  x <- torch_tensor(0:9)
  expect_equal(as_array(x[-1]$to(dtype = torch_int())), 9)
  expect_equal(as_array(x[-2:10]$to(dtype = torch_int())), c(8,9))
  expect_equal(as_array(x[2:N]$to(dtype = torch_int())), c(1:9))
  
  x <- torch_randn(c(10,10,10,10))
  expect_equal(as_array(x[1,..]), as_array(x)[1,,,])
  expect_equal(as_array(x[1,1,..]), as_array(x)[1,1,,])
  expect_equal(as_array(x[..,1]), as_array(x)[,,,1])
  expect_equal(as_array(x[..,1,1]), as_array(x)[,,1,1])
  
  x <- torch_randn(c(10,10,10,10))
  i <- c(1,2,3,4)
  expect_equal(as_array(x[!!!i]), as_array(x)[1,2,3,4])
  i <- c(1,2)
  expect_equal(as_array(x[!!!i,3,4]), as_array(x)[1,2,3,4])
  
  x <- torch_tensor(1:10)
  y <- 1:10
  expect_equal_to_r(x[c(1,3,2,5)]$to(dtype = torch_int()), y[c(1,3,2,5)])
  
  index <- 1:3
  expect_equal_to_r(x[index]$to(dtype = torch_int()), y[index])
  
  x <- torch_randn(10, 10)
  x[c(2,3,1), c(3,2,1)]
  expect_length(x[c(2,3,1), c(3,2,1)], 3)
  
  x <- torch_randn(10)
  expect_equal_to_tensor(x[1:5,..], x[1:5])
  
  x <- torch_randn(10)
  expect_tensor_shape(x[, NULL], c(10, 1))
  expect_tensor_shape(x[NULL, , NULL], c(1, 10, 1))
  expect_tensor_shape(x[NULL, , NULL, NULL], c(1, 10, 1, 1))
  
  x <- torch_randn(10)
  expect_tensor_shape(x[, newaxis], c(10, 1))
  expect_tensor_shape(x[newaxis, , newaxis], c(1, 10, 1))
  expect_tensor_shape(x[newaxis, , newaxis, newaxis], c(1, 10, 1, 1))
  
  x <- torch_randn(10, 10)
  expect_tensor_shape(x[1,,drop=FALSE], c(1, 10))
  expect_tensor_shape(x[..,1,drop=FALSE], c(10, 1))
  expect_tensor_shape(x[..,-1,drop=FALSE], c(10, 1))
})

test_that("indexing error expectations", {
  x <- torch_randn(c(10,10,10,10))
  expect_error(x[1,1,1,1,1])
  x <- torch_tensor(10)
  expect_error(x[0])
  expect_error(x[c(0, 1)])
})

test_that("indexing with boolean tensor", {
  
  x <- torch_tensor(c(-1, -2, 0, 1, 2))
  expect_equal_to_r(x[x < 0], c(-1, -2))
  
  x <- torch_tensor(rbind(
    c(-1, -2, 0, 1, 2),
    c(2, 1, 0, -1, -2)
  ))
  
  expect_equal_to_r(x[x < 0], c(-1, -2, -1, -2))
  
  expect_error(x[x < 0, 1])
  
})

test_that("slice with negative indexes", {
  
  x <- torch_tensor(c(1,2,3))
  expect_equal_to_r(x[2:-1], c(2,3))
  expect_equal_to_r(x[-2:-1], c(2,3))
  expect_equal_to_r(x[-3:-2], c(1,2))
  
  expect_equal_to_r(x[c(-1, -2)], c(3, 2))
  
})

test_that("subset assignment", {
  
  x <- torch_randn(2,2)
  x[1,1] <- torch_tensor(0)
  x
  expect_equal_to_r(x[1,1], 0)
  
  x[1,2] <- 0
  expect_equal_to_r(x[1,2], 0)
  
  x[1,2] <- 1L
  expect_equal_to_r(x[1,2], 1)
  
  x <- torch_tensor(c(TRUE, FALSE))
  x[2] <- TRUE
  expect_equal_to_r(x[2], TRUE)
  
  x <- torch_tensor(rbind(
    c(-1, -2, 0, 1, 2),
    c(2, 1, 0, -1, -2)
  ))
  
  x[x <= 0] <- 1
  expect_true(as_array(torch_all(x > 0)))
  
  x <- torch_tensor(c(1,2,3,4,5))
  x[1:2] <- c(0, 0)
  expect_equal_to_r(x[1:2], c(0, 0))
  
})

test_that("indexing with R boolean vectors", {
  
  x <- torch_tensor(c(1,2))
  expect_equal_to_r(x[TRUE], matrix(c(1,2), nrow = 1))
  expect_equal_to_r(x[FALSE], matrix(data = 1, ncol = 2, nrow = 0))
  expect_equal_to_r(x[c(TRUE, FALSE)], 1)
  
})