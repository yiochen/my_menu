import { statsigProcessingPolicyProvider } from "../_shared/processing_policy.ts";
import { createProcessingJobsHandler } from "./handler.ts";

Deno.serve(createProcessingJobsHandler(statsigProcessingPolicyProvider));
