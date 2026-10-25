// Debug aids for the Android port (no effect unless triggered):
//   files/dump_tree  -> the wx window tree (class, name, shown, wx rect, Qt geometry/visibility) goes to logcat, tag
//                       "prusa-tree"; the flag file is deleted afterwards. See dumptree.sh.
//   files/repaint    -> every top-level window repaints completely (tells stale-paint bugs from layout bugs).
#include <wx/app.h>
#include <wx/module.h>
#include <wx/timer.h>
#include <wx/toplevel.h>
#include <wx/window.h>

#include <QtWidgets/QLabel>
#include <QtWidgets/QListWidget>
#include <QtWidgets/QTreeWidget>
#include <QtWidgets/QWidget>
#include <QtGui/QFontMetrics>

#include <android/log.h>

#include <cstdio>
#include <cstdlib>
#include <algorithm>
#include <string>

namespace {

void dump(wxWindow *w, int depth)
{
    const wxRect r = w->GetRect();
    std::string qt = "-";
    if (QWidget *q = w->GetHandle()) {
        const QRect g = q->geometry();
        qt = std::to_string(g.x()) + "," + std::to_string(g.y()) + " " + std::to_string(g.width()) + "x" + std::to_string(g.height())
            + (q->isVisible() ? " vis" : " hid") + (q->isVisibleTo(q->window()) ? "" : "(to-window:hid)");
        if (QTreeWidget *tw = qobject_cast<QTreeWidget*>(q)) {
            qt += " tree[top=" + std::to_string(tw->topLevelItemCount()) + " hdr=" + (tw->isHeaderHidden() ? "hid" : "vis")
                + " rootdeco=" + (tw->rootIsDecorated() ? "1" : "0");
            qt += std::string(" rootidx=") + (tw->rootIndex().isValid() ? tw->model()->data(tw->rootIndex()).toString().toStdString() : "none")
                + " viewport=" + std::to_string(tw->viewport()->width()) + "x" + std::to_string(tw->viewport()->height())
                + " iconsz=" + std::to_string(tw->iconSize().width()) + "x" + std::to_string(tw->iconSize().height());
            if (tw->topLevelItemCount() > 0 && tw->topLevelItem(0)->childCount() > 0) {
                const QRect r = tw->visualItemRect(tw->topLevelItem(0)->child(0));
                qt += " row0=" + std::to_string(r.x()) + "," + std::to_string(r.y()) + " " + std::to_string(r.width()) + "x" + std::to_string(r.height());
            }
            for (int i = 0; i < std::min(tw->topLevelItemCount(), 2); ++i) {
                QTreeWidgetItem *it = tw->topLevelItem(i);
                qt += " '" + it->text(0).toStdString() + "'(children=" + std::to_string(it->childCount())
                    + (it->isHidden() ? " hidden" : "") + (it->isExpanded() ? " exp" : "") + ")";
                for (int c = 0; c < std::min(it->childCount(), 3); ++c)
                    qt += " >'" + it->child(c)->text(0).toStdString() + "'" + (it->child(c)->isHidden() ? "(hidden)" : "");
            }
            qt += "]";
        }
        if (QListWidget *lw = qobject_cast<QListWidget*>(q)) {
            qt += " list[count=" + std::to_string(lw->count()) + " updates=" + (lw->updatesEnabled() ? "on" : "OFF");
            for (int i = 0; i < std::min(lw->count(), 4); ++i)
                qt += " '" + lw->item(i)->text().toStdString() + "'";
            qt += "]";
        }
        if (QLabel *l = qobject_cast<QLabel*>(q)) {
            int wx_w = 0, wx_h = 0;
            w->GetTextExtent(w->GetLabel(), &wx_w, &wx_h);
            int widest = 0;
            for (const QString &line : l->text().split('\n'))
                widest = std::max(widest, l->fontMetrics().horizontalAdvance(line));
            qt += " label[hint=" + std::to_string(l->sizeHint().width()) + " qt_widest=" + std::to_string(widest)
                + " margin=" + std::to_string(l->margin()) + " indent=" + std::to_string(l->indent())
                + " contents=" + std::to_string(l->contentsRect().width()) + " '" + l->text().left(40).toStdString() + "']";
        }
    }
    __android_log_print(ANDROID_LOG_INFO, "prusa-tree", "%*s%s '%s' %s wx=%d,%d %dx%d qt=%s", depth * 2, "",
        wxString(w->GetClassInfo()->GetClassName()).utf8_str().data(), w->GetName().utf8_str().data(), w->IsShown() ? "shown" : "HIDDEN",
        r.x, r.y, r.width, r.height, qt.c_str());
    for (wxWindow *c : w->GetChildren())
        dump(c, depth + 1);
}

class DebugTimer : public wxTimer
{
public:
    void Notify() override
    {
        const char *home = std::getenv("HOME"); // the app's files directory (bootstrap.cpp)
        if (home == nullptr)
            return;
        const std::string flag = std::string(home) + "/dump_tree";
        if (std::FILE *f = std::fopen(flag.c_str(), "r")) {
            std::fclose(f);
            std::remove(flag.c_str());
            for (wxWindow *tlw : wxTopLevelWindows)
                dump(tlw, 0);
            // the Qt side of the top-level windows: menu/tool/status bars wx does not know about
            for (wxWindow *tlw : wxTopLevelWindows)
                if (QWidget *q = tlw->GetHandle(); q && q->isVisible())
                    for (QObject *o : q->children())
                        if (QWidget *c = qobject_cast<QWidget*>(o)) {
                            const QRect g = c->geometry();
                            __android_log_print(ANDROID_LOG_INFO, "prusa-tree", "QT %s > %s '%s' %d,%d %dx%d %s",
                                q->metaObject()->className(), c->metaObject()->className(), c->objectName().toUtf8().constData(),
                                g.x(), g.y(), g.width(), g.height(), c->isVisible() ? "vis" : "hid");
                        }
            __android_log_write(ANDROID_LOG_INFO, "prusa-tree", "END");
        }
        const std::string repaint = std::string(home) + "/repaint";
        if (std::FILE *f = std::fopen(repaint.c_str(), "r")) {
            std::fclose(f);
            std::remove(repaint.c_str());
            for (wxWindow *tlw : wxTopLevelWindows)
                if (QWidget *q = tlw->GetHandle())
                    q->repaint();
            __android_log_write(ANDROID_LOG_INFO, "prusa-tree", "REPAINTED");
        }
    }
};

class DebugToolsModule : public wxModule
{
public:
    bool OnInit() override
    {
        m_timer.Start(1000);
        return true;
    }
    void OnExit() override { m_timer.Stop(); }

private:
    DebugTimer m_timer;
    wxDECLARE_DYNAMIC_CLASS(DebugToolsModule);
};

wxIMPLEMENT_DYNAMIC_CLASS(DebugToolsModule, wxModule);

} // namespace
