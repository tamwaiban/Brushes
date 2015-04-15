
///  \file CZLayer.h
///  \brief This is the file declare the class CZLayer.
///
///		
///
///  \version	1.0.0
///	 \author	Charly Zhang<chicboi@hotmail.com>
///  \date		2014-10-15
///  \note

#ifndef _CZLAYER_H_
#define _CZLAYER_H_

#include "../CZDefine.h"
#include "../basic/CZImage.h"
#include "../basic/CZColor.h"
#include "../basic/CZMat4.h"
#include "../CZColorBalance.h"
#include "../CZHueSaturation.h"
#include "../basic/CZAffineTransform.h"
#include "../serialization/CZCoding.h"
#include "../CZDataProvider.h"
#include "../CZColorBalance.h"
#include "../CZHueSaturation.h"
#include "../graphic/CZTexture.h"
#include "../graphic/CZGLContext.h"
#include <string>

class CZPainting;
class CZRect;

typedef	enum BlendMode		///< ���ģʽ
{
	kBlendModeNormal,
	kBlendModeMultiply,
	kBlendModeScreen,
	kBlendModeExclusion
} BlendMode;

/// ͼ����
class CZLayer : public CZCoding
{
public:
	CZLayer(CZPainting *painting_);
	~CZLayer();

	/// ͼ���ͼ������
	CZImage *imageData();
	/// �����ض����������ͼ������
	CZImage *imageDataInRect(const CZRect &rect);
	
	/// ����ͼ��
	void basicBlit(CZMat4 &projection);
	/// ����ͼ�㣨�����ƶ�ת������ɫ�����ȣ�
	void blit(CZMat4 &projection);
	/// ���Ӳ�������
	void blit(CZMat4 &projection, CZTexture *maskTexture);
	/// ���ӻ�������
	void blit(CZMat4 &projection, CZTexture *maskTexture, CZColor &bgColor);
	
	/// �����Ƶıʻ��ϲ�����ǰͼ��
	void commitStroke(CZRect &bounds, CZColor &color, bool erase, bool undoable);
	
	/// ������ɫ
	void commitColorAdjustments();
	
	/// �ϲ�����ͼ��
	bool merge(CZLayer *layer);

	/// ���û���ָ��
	void setPainting(CZPainting *painting);
	/// ����ת������û�����ı䣬�򷵻�false��
	bool setTransform(CZAffineTransform &trans);
	/// ��ȡת������
	CZAffineTransform & getTransform();
	/// ���û��ģʽ��û�����ı䣬�򷵻�false��
	bool setBlendMode(BlendMode &bm);
	/// ��ȡ���ģʽ
	BlendMode getBlendMode();
	/// ���ò�͸���ȣ�û�����ı䣬�򷵻�false��
	bool setOpacity(float o);
	/// ��ȡ��͸����
	float getOpacity();
	/// ���õ�����ɫ��û�����ı䣬�򷵻�false��
	bool setColorBalance(CZColorBalance *cb);
	/// ����ɫ������
	bool setHueSaturation(CZHueSaturation *hs);
	/// ����ͼ��ͼ��
	/// 
	///		\param img - ���õ�ͼ��
	///		\ret	   - ��img��Ϊ�գ������ó¹�
	///		\note ���ô˺���������֮ǰ�Ըò�����л���
	bool setImage(CZImage *img);

	/// �л��ɼ���
	void toggleVisibility();
	/// �л�alpha����
	void toggleAlphaLocked();
	/// �л�ͼ������
	void toggleLocked();
	/// ���ÿɼ���
	void setVisiblility(bool flag);
	/// ����alpha����
	void setAlphaLocked(bool flag);
	/// ����ͼ������
	void setLocked(bool flag);
	/// �Ƿ���סͼ��
	bool isLocked();
	/// �Ƿ���סalpha
	bool isAlphaLocked();
	/// �Ƿ�ɼ�
	bool isVisible();
	/// �Ƿ�ɱ༭
	bool isEditable();

	/// ��ȡ���
	char* getUID();

	/// ʵ��coding�Ľӿ�
	void update(CZDecoder *decoder_, bool deep = false);
	void encode(CZCoder *coder_, bool deep = false);

private:
	///���û��ģʽ 
	void configureBlendMode();
	/// ������ת�������			
	void blit(CZMat4 &projection, const CZAffineTransform &transform);

private:
	static unsigned int layerNumber;			///< ͼ�����Ŀ
	bool visible;								///< �Ƿ�ɼ�
	bool alphaLocked;							///< alpha�Ƿ�����
	bool locked;								///< ͼ������
	bool clipWhenTransformed;					///< ͼ��任ʱ�Ƿ����
	CZColorBalance *colorBalance;				///< ������ɫ
	CZHueSaturation *hueSaturation;				///< ����ɫ�����Ͷ�
	BlendMode blendMode;						///< ���ģʽ
	CZAffineTransform transform;				///< �任����
	float opacity;								///< ��͸����[0.0, 1.0]

	CZPainting *ptrPainting;					///< ĳ�λ���
	CZImage *image;								///< ��ͼ��ͼ�����ڽ�����ʼͼ��������
	CZSaveStatus isSaved;						///< ͼ��洢״̬
	CZTexture *myTexture;						///< ��������
	CZTexture *hueChromaLuma;					///

	CZGLContext *ptrGLContext;					///< gl������
	char* uuid;									///< ���
};

#endif