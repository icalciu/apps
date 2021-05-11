import timeit

print("imports complete")

start_time = timeit.default_timer()

SIZE = 1024*1024*16
a = list(range(SIZE))
b = list(range(SIZE))

# Element-wise multiplication
c = [a*b for a,b in zip(a,b)]

end_time = timeit.default_timer()
total_time = end_time - start_time

print("Total time = {}s".format(total_time))
