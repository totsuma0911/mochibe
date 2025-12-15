module ApplicationHelper
  # パンくずリストの生成
  # TOPページ以外で表示し、controller名に応じて最終階層を変更
  def breadcrumbs
    return nil if controller_name == "home"

    case controller_name
    when "chat_sessions"
      [
        { text: "TOP", path: root_path },
        { text: "分析中", path: nil }
      ]
    when "analyses"
      [
        { text: "TOP", path: root_path },
        { text: "分析結果", path: nil }
      ]
    else
      nil
    end
  end
end
