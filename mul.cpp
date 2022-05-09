#include <iostream>
#include <cstring>
#define N 128

char x[N];
char y[N];
int xlen;
int ylen;
int ans[N+N];
int pr;
int tmp;

int strlen(char s[]){//返回结果在eax中
    int ret = 0;
    while(*(s+ret)!='\0')ret++;
    return ret;
}


int main(){
    memset(ans,0,sizeof(ans));

    scanf("%s",x);
    scanf("%s",y);
    xlen = strlen(x);//乘数
    ylen = strlen(y);//被乘数

    for(int i=0;i<xlen;i++)x[i] = x[i] - '0';
    for(int j=0;j<ylen;j++)y[j] = y[j] - '0';

    for(int i=0;i<=xlen/2;i++){
        tmp = x[i];
        x[i] = x[xlen-1-i];
        x[xlen-1-i] = tmp;
    }

    for(int i=0;i<=ylen/2;i++){
        tmp = y[i];
        y[i] = y[ylen-1-i];
        y[ylen-1-i] = tmp;
    }


    for(int i=0;i<xlen;++i)
        for(int j=0;j<ylen;j++)
            ans[i+j] += y[j] * x[i];
        
    pr = 0;
    while(pr<2*N){
        int tmp = ans[pr];
        ans[pr] = tmp%10;
        tmp /= 10;
        if(tmp>0)ans[pr+1]+=tmp;
        pr++;
    }

    for(int i=2*N-1;i>=0;i--){
        if(ans[i]>0){
            pr = i;
            break;
        }
    }


    do{
        printf("%d",ans[pr]);
        pr--;
    }while(pr>=0);


    return 0;
}