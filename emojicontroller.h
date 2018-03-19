#ifndef EMOJICONTROLLER_H
#define EMOJICONTROLLER_H

#include <QObject>


class EmojiController : public QObject
{
    Q_OBJECT
public:
    explicit EmojiController(QObject *parent = nullptr);

signals:

public slots:
    QStringList getEmojis(){ return m_emojis; }
private:
    QStringList m_emojis;
};

#endif // EMOJICONTROLLER_H
