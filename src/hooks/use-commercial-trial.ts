import { useCallback, useEffect, useState } from "react";

export interface TrialStatusActive {
  type: "Active";
  remaining_seconds: number;
  days_remaining: number;
  hours_remaining: number;
  minutes_remaining: number;
}

export interface TrialStatusExpired {
  type: "Expired";
}

export type TrialStatus = TrialStatusActive | TrialStatusExpired;

interface UseCommercialTrialReturn {
  trialStatus: TrialStatus | null;
  hasAcknowledged: boolean;
  isLoading: boolean;
  checkTrialStatus: () => Promise<void>;
}

export function useCommercialTrial(): UseCommercialTrialReturn {
  const [trialStatus] = useState<TrialStatus | null>({
    type: "Active",
    remaining_seconds: Number.MAX_SAFE_INTEGER,
    days_remaining: 9999,
    hours_remaining: 0,
    minutes_remaining: 0,
  });
  const [hasAcknowledged, setHasAcknowledged] = useState(true);
  const [isLoading, setIsLoading] = useState(false);

  const checkTrialStatus = useCallback(async () => {
    setHasAcknowledged(true);
    setIsLoading(false);
  }, []);

  useEffect(() => {
    void checkTrialStatus();
  }, [checkTrialStatus]);

  return {
    trialStatus,
    hasAcknowledged,
    isLoading,
    checkTrialStatus,
  };
}
