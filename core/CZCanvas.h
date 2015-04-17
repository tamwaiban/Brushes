
///  \file CZCanvas.h
///  \brief This is the file declare the class CZCanvas.
///
///	
///
///  \version	1.0.0
///	 \author	Charly Zhang<chicboi@hotmail.com>
///  \date		2014-10-15
///  \note

#ifndef _CZCANVAS_H_
#define _CZCANVAS_H_

#include "basic/CZRect.h"

class CZPainting;

class CZCanvas
{
public:
	struct CZView;
	CZCanvas();
	~CZCanvas();

	/// 设置绘制
	bool setPaiting(CZPainting* p);
	/// 绘制视图
	void drawView();

private:
	/// 在一定区域绘制视图
	void drawViewInRect(CZRect &rect);
public:
	CZPainting *ptrPainting;

private:
	CZRect visibleRect;
	CZView *view;
};

#endif