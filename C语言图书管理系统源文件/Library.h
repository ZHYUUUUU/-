#include<stdio.h>
#include<stdlib.h>
#include<string.h>

char LReader_num[20];

/**********��������**********/
int CONNECT();
int DISCONNECT();
void start_meun();   //��ʼ����
void login_meun();   //��¼���溯��
int login (void);    //�û���¼����
void admin_menu();   //����Ա���ܽ��溯��
void reader_meun();  //���߹��ܽ��溯��
void admin();        //����Ա����
void reader();       //���ߺ���
void admin_reader(); //������ߺ���
void admin_book();   //����ͼ�麯��
void allborrow();    //�鿴�����������
void overdue();      //���ڷ����
void adminreader_menu();
void adminbook_menu();
void addreader();    //���Ӷ��ߺ���
void deletereader(); //ɾ�����ߺ���
void updatereader(); //�޸Ķ��ߺ���
void addbook();      //����ͼ�麯��
void deletebook();   //ɾ��ͼ�麯��
void updatebook();   //�޸�ͼ�麯��
void borrowbook();   //���麯��
void returnbook();   //���麯��
void searchpersonborrow();//�鿴���˽��ĺ���
void updateme();     //�޸ĸ�����Ϣ����
void allbook();      //�鿴����ͼ�麯��
void allreader();    //�鿴���ж��ߺ���


