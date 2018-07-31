#include <unistd.h>

extern void resume(int cor);
extern char *state;
extern int WorldLength, WorldWidth;

void cell(int x, int y) {
    while (1) {
        int my_state = (int)(state[x*WorldWidth+y]);
        int next_state = 0;
        int living_neighbors = 0;
        
        unsigned int i = x == 0 ? WorldLength - 1 : x - 1;
        unsigned int j = 0;
        for (; i != (x + 2) % WorldLength; i = (i + 1) % WorldLength) {
            for (j = y == 0 ? WorldWidth - 1 : y - 1; j != (y + 2) % WorldWidth; j = (j + 1) % WorldWidth) {
                if (x*WorldWidth+y != i*WorldWidth+j && state[i*WorldWidth+j] != 0) {
                    living_neighbors++;
                }
            }
        }
        
        if (my_state > 0) {
            if (living_neighbors == 2 || living_neighbors == 3) {
                next_state = my_state == 9 ? my_state : my_state + 1;
            } else {
                next_state = 0;
            }
        } else if (living_neighbors == 3) {
            next_state = 1;
        } else {
            next_state = 0;
        }

        resume(0);

        state[x*WorldWidth+y] = (char)next_state;

        resume(0);

    }
}

/*
string-related utility functions from lab4
*/
unsigned int strlen (const char *str) {
  int i = 0;
  while (str[i])
  {
	++i;
  }
  return i;
}

#define BUFFER_SIZE 12
 
char buffer[BUFFER_SIZE];

char *itoa(int num) {
	char* p = buffer+BUFFER_SIZE-1;
	int neg = num<0;
	
	if(neg)
	{
		num = -num;
	}
	
	*p='\0';
	do {
		*(--p) = '0' + num%10;
	} while(num/=10);
	
	if(neg) 
	{
		*(--p) = '-';
	}
	
	return p;
}


int positive_atoi(char* str) {
	int ret = 0, i;
	for (i=0; str[i] != 0; i++){
		if (str[i] < '0' || str[i] > '9')
			return -1;
		ret*=10;
		ret+=str[i]-'0';	
	}
	return ret;
}
