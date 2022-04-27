sampleobjects = buffer_manager.o file_manager.o kdbtree.o

kdbtree : $(sampleobjects)
	     g++ -std=c++11 -o kdbtree $(sampleobjects)

kdbtree.o : kdbtree.cpp
	g++ -std=c++11 -c kdbtree.cpp

buffer_manager.o : buffer_manager.cpp
	g++ -std=c++11 -c buffer_manager.cpp

file_manager.o : file_manager.cpp
	g++ -std=c++11 -c file_manager.cpp

clean :
	rm -f *.o
	rm -f sample_run
