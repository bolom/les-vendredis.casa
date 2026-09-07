module BookingInquiriesHelper
  def booking_error_messages(inquiry)
    return inquiry.errors.full_messages unless inquiry.locale == "fr"

    inquiry.errors.map do |error|
      case error.attribute
      when :base then "Ces dates ne sont plus disponibles. Choisissez un autre séjour."
      when :check_in then "Vérifiez la date d’arrivée : elle doit être à venir et respecter les jours d’arrivée autorisés."
      when :check_out then "Vérifiez la date de départ et la durée du séjour."
      when :adults then "Vérifiez le nombre d’adultes et la capacité du logement."
      when :children then "Vérifiez le nombre d’enfants et la capacité du logement."
      when :guest_name then "Indiquez votre nom."
      when :email then "Indiquez une adresse email valide."
      when :contact_consent then "Acceptez d’être contacté au sujet de cette demande."
      else "Vérifiez les informations de votre demande."
      end
    end.uniq
  end
end
