
///  \file CZActiveState.h
///  \brief This is the file declare the CZActiveState Class.
///
///		(description)
///
///  \version	1.0.0
///	 \author	Charly Zhang<chicboi@hotmail.com>
///  \date		2014-10-28
///  \note		It is a Singleton

#ifndef _CZACTIVESTATE_H_
#define _CZACTIVESTATE_H_

#include "CZSpiralGenerator.h"
#include "CZStampGenerator.h"
#include "CZNotificationCenter.h"
#include "CZColor.h"
#include <string>

/// ����״̬��
class CZActiveState :public CZObserver
{
public:
	/// ��ȡ����
	static CZActiveState * getInstance()
	{
		static CZActiveState instance;   //�ֲ���̬����  
		return &instance; 
	}
	/// ��ȡ���һ����ˢ������
	CZStampGenerator * getRandomGenerator(){return NULL;};
	/// ʵ��Observer�ӿ�
	void updateObserver(std::string &notificationName, void* data = NULL){};

private:
	CZActiveState(){ initial(); }   //���캯����˽�е�
	CZActiveState(const CZActiveState &);
	CZActiveState & operator = (const CZActiveState &);
	~CZActiveState(){ destroy(); }

	/// ��ʼ������
	bool initial()
	{ 
		brush = new CZBrush(new CZSpiralGenerator);
		paintColor = CZColor::greenColor();
		return true; 
	};
	/// ���ٺ���
	bool destroy() { if(brush != NULL) {delete brush; brush = NULL;} return true;};

public:
	CZBrush *brush;
	CZColor paintColor;
};

#endif