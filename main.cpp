#include <iostream>

using namespace std;

string add(string a, string b);
bool check_int(string a);
string flip(string a);

int main()
{
    string l1 = "123456";
    string l2 = "234";
    add(l1,l2);
    return 0;
}



string add(string a, string b)
{
    int length;
    int leftover = 0;
    string c; //c will be flipped, so it has to be flipped back before return
    if(!check_int(a) or !check_int(b))
    {
        cout << "One of the strings can't be converted to integer, it contains illegal characters";
        return "error";
    }
    if(a.size() >= b.size())
    {
        length = a.size();
    }
    else
    {
        length = b.size();
    }
    a = flip(a);
    b = flip(b);
    for(int i = length - 1; i >= 0; i--)
    {
        int int_a = int(a[i]) - 48;
        int int_b = int(b[i]) - 48;
        int int_c = leftover;
        cout << leftover << endl;
        if(int_a < 0 or int_a > 9)
        {
            int_a = 0;
        }
        if(int_b < 0 or int_b > 9)
        {
            int_b = 0;
        }
        int_c += int_a + int_b;

        leftover = 0;
        while(int_c > 9)
        {
            int_c -= 10;
            leftover += 1;
        }
        //cout << int_c << " " << leftover << endl;
        //cout << int_a << " + " << int_b << " = " << int_c << endl;
        //c[i] = int_c;
        //cout << int_c << " " << leftover << endl;
    }
}

bool check_int(string a)
{
    for(int i = 0; i< a.size(); i++)
    {
        if(int(a[i]) - 48 < 0 or int(a[i]) - 48 > 9)
        {
            return 0;
        }
    }
    return 1;
}

string flip(string a)
{
    string b = a;
    if(a.size() == 0)
    {
        return a;
    }
    for(int i = 0;i < a.size();i++)
    {
        b[i] = a[a.size() - i - 1];
    }
    return b;
}
